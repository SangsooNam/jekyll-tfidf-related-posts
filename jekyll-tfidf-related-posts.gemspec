# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "jekyll-tfidf-related-posts"
  spec.version       = "0.1.7"
  spec.authors       = ["Sangsoo Nam"]
  spec.email         = ["sangsoo.ted@gmail.com"]
  spec.summary       = %q{Jekyll plugin to show related posts based on the content, tags, and categories.}
  spec.description   = %q{Jekyll plugin to show related posts based on the content, tags, and categories.  The similarity is calculated using TF-IDF(term frequency-inverted document frequency). Since tags and categories are use-defined values, those are considered with higher weights than a content while calculating.}
  spec.homepage      = "https://github.com/SangsooNam/jekyll-tfidf-related-posts"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ["lib"]

  spec.add_dependency "jekyll", ">= 3.0"
  spec.add_dependency "stopwords-filter", "~> 0.4"
  spec.add_dependency "fast-stemmer", "~> 1.0"
  spec.add_dependency "pqueue", "~> 2.1"
  spec.add_dependency "nmatrix", "~> 0.2"
end
