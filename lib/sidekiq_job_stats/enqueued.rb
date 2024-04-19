module SidekiqJobStats
  class Enqueued
    attr_accessor :job_class

    def initialize(job_class)
      @job_class = job_class
    end

    def track
      Sidekiq.redis do |conn|
        conn.incr(job_stats_enqueued_key)
      end
    end

    def jobs_enqueued
      Sidekiq.redis do |conn|
        conn.get(job_stats_enqueued_key).to_i
      end
    end

    private

    def job_stats_enqueued_key
      "stats:jobs:#{job_class}:stats"
    end
  end
end
