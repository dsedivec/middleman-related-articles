require 'middleman'
require_relative 'store'
require_relative 'indexer'

module Middleman::RelatedArticles
  class Extension < Middleman::Extension
    DEFAULT_STORE_NAME = 'related-articles.yaml'

    self.supports_multiple_instances = true

    option :name, nil, "Blog name, if given must match the name of a blog"
    option :index, nil, "Where the index will be stored"
    option :num_related, 10, "Number of related articles to generate"
    option :update_before_build, true,
      "Should the index be updated before a build?"

    def initialize(app, options_hash={}, &block)
      super
      if options.num_related <= 0
        raise "num_related option must be a positive integer"
      end
    end

    def after_configuration
      # I'm a little concerned that the blog might not always get its
      # after_configuration run before ours, in which case this call
      # (or something else below) might fail.
      @blog = @app.blog(options.name)
      raise "can't find blog \"#{options.name}\"" unless @blog
      store_path = options.index || DEFAULT_STORE_NAME
      store_path = File.absolute_path(store_path, @app.root)
      store = Store.new(store_path)
      # Looking at the code of other Markdown extensions, I don't see
      # a better way to get these objects visible to the helper, so we
      # add methods on blog.  (Better than adding them on the
      # Application instance, right?  Right?)
      @blog.define_singleton_method(:related_articles_store) do
        store
      end
      num_related = options.num_related
      @blog.define_singleton_method(:num_related_articles) do
        num_related
      end
    end

    def before_build
      if options.update_before_build
        Indexer.update_index(@blog, @app.sitemap)
      end
    end

    helpers do
      # Returns an array of `BlogArticle` instances that are related
      # to the given `article`, ordered from most relevant to least.
      #
      # @param article [Middleman::Blog::BlogArticle] the article for
      #   you which you want related articles; defaults to the current
      #   article when Middleman is producing the page for an
      #   individual article
      # @return [Array] list of zero or more `BlogArticle` instances
      #   related to the given article
      def related_articles(target_article = nil)
        store = current_article.blog_data.related_articles_store
        # I wonder what happens when there is no concept of a "current
        # article," e.g. when producing the index page?
        target_article ||= current_article
        article_paths = store.related[target_article.path] || []
        article_paths.map { |path| sitemap.find_resource_by_path(path) }
      end
    end
  end
end
