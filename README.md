# Middleman::RelatedArticles

This is an extension for [Middleman's blog extension][] to automatically identify recent articles using [latent semantic indexing (LSI)][lsi], a fancy algorithm for identifying relationships between unstructured texts.

[Middleman's blog extension]: https://github.com/middleman/middleman-blog
[lsi]: https://en.wikipedia.org/wiki/Latent_semantic_indexing

This extension was heavily inspired by [Jekyll][]'s use of LSI for related articles, and that's also where I learned about the [Classifier] gem, which does all the heavy lifting of this extension.

[Jekyll]: http://jekyllrb.com
[Classifier]: https://github.com/cardmagic/classifier/

## Installation

You must already be using Middleman's blogging extension, or else this extension is worthless to you.

I haven't currently had the guts to upload this as a gem yet, so try adding this line to your blog's `Gemfile`:

```ruby
gem 'middleman-related-articles', :git => 'https://github.com/dsedivec/middleman-related-articles.git'
```

And then execute:

    $ bundle

You could probably also download/clone the repository and `rake install` it.

**This gem may be very slow unless** you also install [GNU Scientific Library][gsl] and [rb-gsl][].  I've personally accomplished this on my Mac using [MacPorts][] (`port install gsl`), adding `gem 'rb-gsl'` to my `Gemfile`, and finally running `bundle` to install rb-gsl.  (As of this writing, this is a lie: I had [a problem with rb-gsl and MacPorts's GSL][gsl-gslcblas-issue].  I fixed it by patching and installing the rb-gsl gem locally.)

[gsl]: https://www.gnu.org/software/gsl/
[rb-gsl]: https://github.com/blackwinter/rb-gsl
[MacPorts]: https://www.macports.org/
[gsl-gslcblas-issue]: https://github.com/blackwinter/rb-gsl/issues/3

## Usage

First, activate the extension in your `config.rb`:

```ruby
activate :related_articles
```

There are a few options you can tweak:

```ruby
activate :related_articles do |related|
  # The "name" option is only useful if you have more than one blog.
  # This name must match the blog's name.  Defaults to the default
  # blog.
  #
  # Note that this extension can (hopefully) be used on more than one
  # blog by activating this extension multiple times, but beware that
  # you'll also need to change the following "index" option for each
  # blog as well.
  related.name = 'My blog'

  # Path to the index file that will be created.  Defaults to
  # related-articles.yaml in your Middleman root directory.
  related.index = '/foo/bar.yaml'

  # Number of related articles to generate.  Defaults to 10.
  # Changing this probably won't make rebuilding the related articles
  # index any slower or faster, though it will take more memory and
  # space on disk.
  related.num_related = 10

  # If true, the extension will always check to see if the related
  # articles index should be updated at the beginning of
  # "middleman build".  Defaults to true.
  related.update_before_build = true
end
```

After activating the extension, you will need to build the index of related articles by running `middleman related`.  This can be slow on a large number of articles, but the index will only be regenerated if articles are added, deleted, or changed since the last run.  If you haven't already, I'm told installing rb-gsl can speed up indexing by a factor of ten.

By default, when building your site with e.g. `middleman build`, this extension will automatically rebuild the index if articles have been added, deleted, or changed.

Finally, in your templates, you can use the `related_articles` helper to get a list of related articles for an article.  For example, you could add this to the layout for your individual articles:

```erb
<h2>Related articles</h2>
<ul>
  <% related_articles.each do |article| %>
    <li><%= link_to(article.title, article)  %></li>
  <% end %>
</ul>
```

`related_articles` takes an optional article, which is the article for which you want related articles.  For example, here's how you could produce a list of related articles for every article in your blog:

```erb
<ul>
  <% blog.articles.each do |article| %>
    <li>
      <%= article.title %>:
      <ul>
        <% related_articles(article).each do |related_article| %>
          <li><%= link_to(related_article.title, related_article) %></ul>
        <% end %>
      </ul>
    </li>
  <% end %>
</ul>
```

## Contributing

1. Fork it (http://github.com/dsedivec/middleman-related-articles/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
