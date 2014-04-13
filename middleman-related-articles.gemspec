# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'middleman-related-articles/version'

Gem::Specification.new do |spec|
  spec.name          = "middleman-related-articles"
  spec.version       = Middleman::RelatedArticles::VERSION
  spec.authors       = ["Dale Sedivec"]
  spec.email         = ["dale@codefu.org"]
  spec.summary       = "Find related blog articles using LSI"
  spec.description   = %q{

    For users of middleman-blog, this indexes your blog articles using
    latent semantic indexing (LSI) to suggest related articles for
    each.

  }
  spec.homepage      = "https://github.com/dsedivec/middleman-related-articles"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.has_rdoc      = "yard"

  # I'm requiring 1.9.2 because I use define_singleton_method,
  # require_relative, and Psych.  (Is there a way to require Psych but
  # accept the version that is in stdlib?)  Beware that I've only
  # tested under 2.1, though.
  spec.required_ruby_version = ">= 1.9.2"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "redcarpet"

  spec.add_runtime_dependency "middleman"
  spec.add_runtime_dependency "classifier"
  spec.add_runtime_dependency "nokogiri"
end
