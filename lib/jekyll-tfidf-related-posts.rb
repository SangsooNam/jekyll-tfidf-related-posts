require 'rubygems'
require 'jekyll'
require 'fast_stemmer'
require 'stopwords'
require 'pqueue'
require 'nmatrix'

module SangsooNam
module Jekyll
  class TFIDFRelatedPosts
    def initialize
      @docs = Array.new
      @keywords = Array.new
      @tags_and_categories = Array.new
      @stopwords_filter = Stopwords::Snowball::Filter.new('en')
    end

    def add_post(post)
      tags = post.data['tags'].map { |e| "@tag:" + e }.map(&:to_sym)
      categories = post.data['categories'].map { |e| "@category:" + e }.map(&:to_sym)
      doc = {
        post: post,
        content: (stem(post.content) + stem(post.data['title']) + tags + categories)
      }
      @docs << doc
      @keywords += doc[:content]
      @tags_and_categories += tags + categories
    end

    def build(site)
      @keywords.uniq!
      @tags_and_categories.uniq!
      @weights = custom_weights(@tags_and_categories)
      related = build_related_docs_with_score(site.config['related_posts_count'] || 4)

      @docs.each do |doc|
        doc[:post].instance_variable_set(:@related_posts,related[doc].map { |x| x[:post] })
      end
    end

    private

    def build_related_docs_with_score(count = 8)
      dc = document_correleation
      result = Hash.new
      count = [count, @docs.size].min

      @docs.each_with_index do |doc, index|
        queue = PQueue.new(dc.row(index).each_with_index) do |a, b|
          a[0] > b[0]
        end

        result[doc] = []
        count.times do
          score, id = queue.pop
          begin
            result[doc] << {
              score: score,
              post: @docs[id][:post]
            }
          rescue
            break
          end
        end
      end

      return result
    end

    def document_correleation()
      scores = tfidf
      result = scores.dot(scores.transpose)

      result.each_with_indices do |_, u, v|
        if u != v
          result[u, v] /= (result[u, u] + result[v, v] - result[u, v])
        else
          result[u, v] = 0.0
        end
      end

      return result
    end

    def bag_of_words
      result = NMatrix.new([@docs.size, @keywords.size], 0.0)
      @max = NMatrix.new([@docs.size], 0.0)

      result.each_with_indices do |_, pi, ki|
        result[pi, ki] = @docs[pi][:content].count(@keywords[ki])

        if result[pi, ki] > @max[pi]
          @max[pi] = result[pi, ki]
        end
      end

      @bag_of_words = result.dup
      return result
    end

    def term_frequency
      result = bag_of_words

      result.rows.times do |r|
        result[r, 0..-1] *= @weights
        result[r, 0..-1] /= @max[r]
      end

      return result
    end

    def custom_weights(terms, weight = 8.0)
      result = NMatrix.new([1, @keywords.size], 1.0)

      terms.each do |term|
        result[0, @keywords.index(term)] = weight
      end

      return result
    end

    def inverse_document_frequency
      result = NMatrix.new([1, @keywords.size], 0.0)

      @bag_of_words.each_column do |column|
        occurences = column.reduce do |m, c|
          m + (c > 0 ? 1.0 : 0.0)
        end

        result[0, column.offset[1]] = Math.log(column.size / occurences) if occurences > 0
      end

      return result
    end

    def tfidf
      result = term_frequency
      idf = inverse_document_frequency

      result.rows.times do |r|
        result[r, 0..-1] *= idf
      end

      return result
    end

    def stem(data)
      data = data.gsub(/{%.+%}/, ' ') # Replace liquid templates
      tokenized = data.scan(/\w+/).map(&:downcase)
      filtered = @stopwords_filter.filter(tokenized)
      stemmed = filtered.map(&:stem).select{|s| s.length > 1}.map(&:to_sym)
      return stemmed
    end
  end
end
end

Jekyll::Hooks.register :site, :pre_render do |site|
  Jekyll.logger.info("Building TFIDF index...")
  tfidf = SangsooNam::Jekyll::TFIDFRelatedPosts.new
  site.posts.docs.each do |x|
      tfidf.add_post(x)
  end

  Jekyll.logger.info("Replaceing Related Posts...")
  tfidf.build(site)
end
