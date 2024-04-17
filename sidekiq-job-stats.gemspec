# frozen_string_literal: true

require_relative "lib/sidekiq/job/stats/version"

Gem::Specification.new do |spec|
  spec.name = "sidekiq-job-stats"
  spec.version = Sidekiq::Job::Stats::VERSION
  spec.authors = ["isliusar"]
  spec.email = ["isliusar@liaisonedu.com"]

  spec.description = "Tracks jobs performed, failed, and the duration of the last 100 jobs for each job type."
  spec.homepage = "https://github.com/sliusar-ihor/sidekiq-job-stats"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"


  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "sidekiq", ">= 6"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
