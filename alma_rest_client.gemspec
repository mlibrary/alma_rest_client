require_relative "lib/alma_rest_client/version"

Gem::Specification.new do |spec|
  spec.name = "alma_rest_client"
  spec.version = AlmaRestClient::VERSION
  spec.authors = ["Monique Rio"]
  spec.email = ["mrio@umich.edu"]

  spec.summary = ""
  spec.description = ""
  spec.homepage = "https://github.com/mlibrary/alma_rest_client"
  spec.license = "BSD 3"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.2.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.pkg.github.com/mlibrary"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rexml"
  spec.add_dependency "faraday"
  spec.add_dependency "httpx"
  spec.add_dependency "faraday-retry"
  spec.add_dependency "activesupport", "~> 8.0"

  spec.add_development_dependency "byebug"
  spec.add_development_dependency "standard"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "climate_control"
end
