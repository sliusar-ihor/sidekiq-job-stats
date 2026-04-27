# frozen_string_literal: true

require_relative "sidekiq_job_stats/version"
require_relative "sidekiq_job_stats/middleware"
require_relative "sidekiq_job_stats/web_extension"
require_relative "sidekiq_job_stats/statistic"
require_relative "sidekiq_job_stats/enqueued"
require_relative "sidekiq_job_stats/history"

require 'sidekiq/web'

module Sidekiq
  def self.job_stats_max_count=(value)
    @job_stats_max_count = value
  end

  def self.job_stats_max_count
    @job_stats_max_count || 1000
  end
end

if Sidekiq::MAJOR >= 8
  Sidekiq::Web.configure do |config|
    config.register_extension(
      SidekiqJobStats::WebExtension,
      name: "job_stats",
      tab: ["Job stats"],
      index: "job_stats",
      root_dir: File.expand_path("../web", __FILE__),
      asset_paths: ["css"]
    )
  end
else
  Sidekiq::Web.register(SidekiqJobStats::WebExtension)
  Sidekiq::Web.tabs['Job stats'] = 'job_stats'
end




