require 'psych'

module Middleman::RelatedArticles
  # Loads and stores information about related articles.
  #
  # An instance contains:
  #
  # - A map between articles and their related articles.
  # - Information about each of the articles at the time they were
  #   indexed, used when determining whether or not the index needs to
  #   be rebuilt.
  class Store
    VERSION = 1

    # Map between `BlogArticle` paths and partial `File.stat` results.
    attr_accessor :stats

    # Map between `BlogArticle` paths and an array of paths of related
    # blog articles.
    attr_accessor :related

    # Create a new related articles store.
    #
    # If it exists and seems to have the right format, the store will
    # be initialized with the data from the file at `path`.  Otherwise
    # the store will be initially empty.
    #
    # @param path [String] path to the YAML file containing the
    #   information from a prior build of the related articles index
    def initialize(path)
      @path = path
      articles = {}
      begin
        docs = Psych.load_stream(File.open(path, "r"), path)
        if docs[0] == {version: VERSION}
          articles = docs[1] || {}
        end
      rescue StandardError
        # Ignore this, pretend like the path doesn't exist (and indeed
        # it may not).  I hope StandardError is the right place in the
        # exception hierarchy for me to catch here.
      end
      @stats, @related = {}, {}
      articles.each_pair do |article_path, article_info|
        article_stat, related = article_info.values_at(:stat, :related)
        @stats[article_path] = article_stat if article_stat
        @related[article_path] = related if related
      end
    end

    # Write the related articles index to the `path` supplied at
    # instantiation.
    def save
      File.open(@path, "w") do |file|
        Psych.dump({version: VERSION}, file)
        doc = {}
        @stats.each_pair do |article_path, article_stat|
          doc[article_path] = {
            stat: article_stat,
            related: @related[article_path] || [],
          }
        end
        Psych.dump(doc, file)
      end
    end
  end
end
