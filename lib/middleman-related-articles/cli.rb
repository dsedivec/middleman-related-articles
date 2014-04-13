require 'middleman'
require 'thor'
require_relative 'indexer'

module Middleman::Cli
  # Implements the "related" subcommand for the Middleman CLI.
  class RelatedArticles < Thor
    namespace :related

    desc 'related', 'Rebuild the related articles index'

    method_option "blog", aliases: "-b",
      desc: "Name of the blog to index"

    def related
      app = Middleman::Application.server.inst do
        config[:environment] = :build
      end
      if !app.respond_to?(:blog)
        raise Thor::Error, "you must activate the blog extension"
      end
      blog = app.blog(options[:blog])
      changed = Middleman::RelatedArticles::Indexer.update_index(blog,
                                                                 app.sitemap)
      puts "Index already up to date" if not changed
    end
  end
end
