require_relative 'lib/activerecord-covering-index/version'

Gem::Specification.new do |spec|
  spec.name          = "activerecord-covering-index"
  spec.version       = ActiverecordCoveringIndex::VERSION
  spec.authors       = ["Tiger Watson"]
  spec.email         = ["tigerwnz@gmail.com"]

  spec.summary       = %q{Create covering indexes in Rails with PostgreSQL}
  spec.description   = %q{Extends ActiveRecord to support covering indexes in PostgreSQL using the INCLUDE clause.}
  spec.homepage      = "https://gitlab.com/schlock/activerecord-covering-index"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(.gitlab|spec|gemfiles)/}) }
  end

  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 5.2", "< 7.1"
  spec.add_dependency "pg"

  spec.add_development_dependency "rspec", "~> 3.10"
  spec.add_development_dependency "appraisal", "~> 2.4"
end
