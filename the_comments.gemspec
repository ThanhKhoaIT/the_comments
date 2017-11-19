# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'the_comments/version'

Gem::Specification.new do |gem|
  gem.name          = "fuck_comments"
  gem.version       = TheComments::VERSION
  gem.authors       = ["Khoa Nguyen"]
  gem.email         = ["thanhkhoait@gmail.com"]
  gem.description   = %q{ Comments with threading for Rails 4 }
  gem.summary       = %q{ fuck_comments fork from the-trash/the_comments }
  gem.homepage      = "https://github.com/ThanhKhoaIT/the_comments"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'state_machine',     '~> 1.2.0'
  gem.add_dependency 'the_sortable_tree', '~> 2.5.0'
  gem.add_dependency 'the_simple_sort',   '~> 0.0.2'
end
