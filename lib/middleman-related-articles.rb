require 'middleman-related-articles/version'
require 'middleman-related-articles/cli'

::Middleman::Extensions.register(:related_articles) do
  require 'middleman-related-articles/extension'
  ::Middleman::RelatedArticles::Extension
end
