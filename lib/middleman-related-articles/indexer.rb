require 'set'
require 'nokogiri'
require 'classifier'

module Middleman::RelatedArticles
  # Functions to index Middleman blog articles.
  module Indexer
    # Update the related articles index for the given blog, if
    # necessary.
    #
    # Doing an update on many articles can take relatively long, so
    # the related article information is only updated if an existing
    # entry's file modification time or size has changed, or if
    # articles have been added or deleted.
    #
    # Note that this method cannot be used unless Middleman has loaded and
    # initialized the related articles {Extension}.
    #
    # @param blog [Middleman::Blog::BlogData] the blog which may have
    #   its index updated
    # @param sitemap [Middleman::Sitemap] the sitemap, used to fetch
    #   blog articles
    # @return [Boolean] `true` if the index was updated, `false` if it
    #   was not (because no changes were detected)
    def self.update_index(blog, sitemap)
      store = blog.related_articles_store
      stats = store.stats
      if need_to_rebuild?(blog, sitemap, stats)
        log "Need to rebuild related articles"
        index = Classifier::LSI.new(auto_rebuild: false)
        log "Reading content to be indexed"
        article_text = {}
        blog.articles.each do |article|
          article_text[article] = text = Nokogiri::HTML(article.body).text
          index.add_item(article.path) { text }
          stats[article.path] = stat_file(article.source_file)
        end
        log "Building index"
        index.build_index
        log "Determining related articles"
        related = store.related
        num_related = blog.num_related_articles
        blog.articles.each do |article|
          text = article_text[article] || Nokogiri::HTML(article.body).text
          related_articles = index.find_related(text, num_related + 1)
          related[article.path] = related_articles - [article.path]
        end
        store.save
        true
      else
        false
      end
    end

    private

    def self.log(message)
      puts "Related articles: #{message}"
    end

    def self.stat_file(path)
      stat = File.stat(path)
      return {mtime: stat.mtime, size: stat.size}
    end

    def self.need_to_rebuild?(blog, sitemap, stats)
      blog.articles.each do |article|
        return true unless stats.has_key?(article.path)
      end
      stats.each_pair do |path, indexed_stat|
        article = sitemap.find_resource_by_path(path)
        return true unless article
        stat = stat_file(article.source_file)
        return true unless stat == indexed_stat
      end
      false
    end
  end
end
