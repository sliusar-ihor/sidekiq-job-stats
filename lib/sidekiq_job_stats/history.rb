module SidekiqJobStats
  class History
    def initialize(job_data, job_class)
      @job_data = job_data
      @job_class = job_class
    end

    def track
      push_history
    end

    def self.job_history_key(job_class)
      "stats:jobs:#{job_class}:history"
    end

    def histories_recordable
      @histories_recordable || 100
    end

    private

    def push_history
      return if Sidekiq.history_max_count.zero?

      Sidekiq.redis do |conn|
        conn.lpush(self.class.job_history_key(@job_class), @job_data.to_json)
        conn.ltrim(self.class.job_history_key(@job_class), 0, Sidekiq.history_max_count)
      end
    end
  end
end


