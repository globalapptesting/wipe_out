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
  s.summary = ".. "
  s.description = ".."
  s.license = "internal"
  s.homepage = "https://github.com/GlobalAppTesting/wipe-out"
  s.metadata = {
    "homepage_uri" => "https://github.com/GlobalAppTesting/wipe-out",
    "changelog_uri" => "https://github.com/GlobalAppTesting/wipe-out/blob/main/CHANGELOG.md",
    "source_code_uri" => "https://github.com/GlobalAppTesting/wipe-out",
    "bug_tracker_uri" => "https://github.com/GlobalAppTesting/wipe-out/issues"
  }

  s.files =
    Dir.chdir(File.expand_path(__dir__)) do
      `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
    end

  s.add_dependency("attr_extras", "~> 6.2")
  s.add_dependency("zeitwerk", "~> 2.4.2")

  s.add_development_dependency("combustion", "~> 1.3")
  s.add_development_dependency("factory_bot", "~> 6.2")
  s.add_development_dependency("pry", "~> 0.14.1")
  s.add_development_dependency("rails", "~> 6.1")
  s.add_development_dependency("rspec", "~> 3.10")
  s.add_development_dependency("simplecov", "~> 0.21.1")
  s.add_development_dependency("sqlite3", "~> 1.4.2")
  s.add_development_dependency("standard", "~> 1.1.4")
  s.add_development_dependency("super_diff", "~> 0.6.2")
  s.add_development_dependency("webrick")
  s.add_development_dependency("yard", "~> 0.9")
end
