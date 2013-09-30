# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fingerprints/version'

Gem::Specification.new do |gem|
  gem.name          = "fingerprints"
  gem.version       = Fingerprints::VERSION
  gem.authors       = ["Philip Hallstrom"]
  gem.email         = ["philip@pjkh.com"]
  gem.description   = %q{Make it easy to track who created/updated your models.}
  gem.summary       = %q{Make it easy to track who created/updated your models.}
  gem.homepage      = "https://github.com/phallstrom/fingerprints"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
