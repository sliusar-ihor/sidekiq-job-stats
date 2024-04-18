module SidekiqJobStats
  class Enqueued
    def initialize(job_data, job_class)
      @job_data = job_data
      @job_class = job_class
    end

    def track
      Sidekiq.redis do |conn|
        conn.incr(self.class.job_stats_enqueued_key(@job_class))
      end
    end

    def self.job_stats_enqueued_key(job_class)
      "stats:jobs:#{job_class}:stats"
    end
  end
end
