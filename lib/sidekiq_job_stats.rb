# frozen_string_literal: true

require_relative "sidekiq_job_stats/version"
require_relative "sidekiq_job_stats/middleware"
require_relative "sidekiq_job_stats/web_extension"
require_relative "sidekiq_job_stats/statistic"
require_relative "sidekiq_job_stats/enqueued"
require_relative "sidekiq_job_stats/history"

require 'sidekiq/web'

module Sidekiq
  def self.history_max_count=(value)
    @history_max_count = value
  end

  def self.history_max_count
    @history_max_count || 1000
  end
end

Sidekiq::Web.register(SidekiqJobStats::WebExtension)
Sidekiq::Web.tabs['History'] = 'history'
