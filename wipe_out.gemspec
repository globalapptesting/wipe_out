lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# Maintain your gem's version:
require "wipe_out/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "wipe_out"
  s.version = WipeOut::VERSION

  s.authors = ["Michał Foryś", "Piotr Król"]
  s.email = %w[developers@globalapptesting.com michal@globalapptesting.com]

  s.required_ruby_version = ">= 3.0.0"
  s.summary = "Library for removing and clearing data in Rails ActiveRecord models."
  s.description = "Library for removing and clearing data in Rails ActiveRecord models." \
    " Allows to define data removal policy with its own, easy to understand, DSL."
  s.license = "MIT"
  s.homepage = "https://github.com/GlobalAppTesting/wipe_out"
  s.metadata = {
    "homepage_uri" => "https://github.com/GlobalAppTesting/wipe_out",
    "changelog_uri" => "https://github.com/GlobalAppTesting/wipe_out/blob/main/CHANGELOG.md",
    "source_code_uri" => "https://github.com/GlobalAppTesting/wipe_out",
    "bug_tracker_uri" => "https://github.com/GlobalAppTesting/wipe_out/issues"
  }

  s.files =
    Dir.chdir(File.expand_path(__dir__)) do
      `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
    end

  s.add_dependency("attr_extras", ">= 6.0", "< 8.0")
  s.add_dependency("observer", "~> 0.1.0")
  s.add_dependency("zeitwerk", ">= 2.4")

  s.add_development_dependency("combustion", "~> 1.5")
  s.add_development_dependency("factory_bot", "~> 6.5")
  s.add_development_dependency("rails", "~> 7.0")
  s.add_development_dependency("rspec", "~> 3.10")
  s.add_development_dependency("simplecov", "~> 0.21.1")
  s.add_development_dependency("sqlite3", "~> 2.6")
  s.add_development_dependency("standard", "~> 1.31")
  s.add_development_dependency("super_diff", "~> 0.15")
  s.add_development_dependency("webrick")
  s.add_development_dependency("yard", "~> 0.9.37")
end
