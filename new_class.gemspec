# -*- encoding: utf-8 -*-
require File.expand_path("../lib/new_class/version", __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Paul Engel"]
  gem.email         = ["paul.engel@holder.nl"]
  gem.description   = %q{Define variable dependent classes without evalling}
  gem.summary       = %q{Define variable dependent classes without evalling}
  gem.homepage      = "https://github.com/archan937/new_class"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "new_class"
  gem.require_paths = ["lib"]
  gem.version       = NewClass::VERSION

  gem.add_dependency "activesupport", ">= 3.0.0"
end