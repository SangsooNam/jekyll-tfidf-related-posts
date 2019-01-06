# jekyll-tdidf-related-posts

[![Gem Version](https://badge.fury.io/rb/jekyll-tfidf-related-posts.svg)](https://rubygems.org/gems/jekyll-tfidf-related-posts)
[![DUB](https://img.shields.io/dub/l/vibe-d.svg)](LICENSE.txt)

[Jekyll](http://jekyllrb.com) plugin to show related posts based on the content, tags, and categories. The similarity is calculated using TF-IDF(term frequency-inverted document frequency). Since tags and categories are use-defined values, those are considered with higher weights than a content while calculating.

### How to install

1. Install the gem `jekyll-tdidf-related-posts`.
```
$ gem install jekyll-tdidf-related-posts
```
2. Add `jekyll-tdidf-related-posts` plugin in `_config.xml`.
```yaml
plugins:
  - jekyll-tdidf-related-posts
```
3. Run `jekyll build` or `jekyll serve`


### How to use
This plugin calculates related posts and replaces `site.related_posts` containing recent 10 posts by default. So, you can render related posts by iterating `site.related_posts`.

```java
{% for post in site.related_posts %}
  {% include related-post.html %}
{% endfor %}
```

> GitHub Pages supports only [these plugins](https://pages.github.com/versions/). For GitHub Pages, you need to generate your site locally and then push static files to GitHub Pages site.

### Configuration

By default, there are 4 related posts. You can configure it in the `_config.yml`

```
related_posts_count: 8
```
