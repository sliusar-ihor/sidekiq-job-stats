module SidekiqJobStats
  class History
    attr_accessor :job_class

    def initialize(job_class)
      @job_class = job_class
    end

    def track(job_data)
      push_history(job_data)
    end

    def histories_recordable
      @histories_recordable || 100
    end

    def job_histories(start = 0, limit = 100)
      Sidekiq.redis do |conn|
        conn.lrange(job_history_key, start, start + limit - 1).map { |h| JSON.parse(h) }
      end
    end

    def histories_recorded
      Sidekiq.redis do |conn|
        conn.llen(job_history_key)
      end
    end

    private

    def job_history_key
      "stats:jobs:#{job_class}:history"
    end

    def push_history(job_data)
      return if Sidekiq.job_stats_max_count.zero?

      Sidekiq.redis do |conn|
        conn.lpush(job_history_key, job_data.to_json)
        conn.ltrim(job_history_key, 0, Sidekiq.job_stats_max_count)
      end
    end
  end
end


