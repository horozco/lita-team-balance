Gem::Specification.new do |spec|
  spec.name          = "lita-team-balance"
  spec.version       = "0.1.0"
  spec.authors       = ["Hernan Orozco"]
  spec.email         = ["horozco15@gmail.com"]
  spec.description   = "This is an extension for the lito team plugin at: https://github.com/EdgarOrtegaRamirez/lita-team"
  spec.summary       = "Create two balanced teams from a given one. Set scores for members in the team."
  spec.homepage      = "https://github.com/horozco/lito-team-balance"
  spec.license       = "MIT"
  spec.metadata      = { "lita_plugin_type" => "handler" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", ">= 4.7"
  spec.add_runtime_dependency "terminal-table", ">= 1.5.2"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", ">= 3.0.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "coveralls"
end
