module SidekiqJobStats
  class MemoryUsage
    MEMORY_PERIOD_EXPIRE = {:day => 60 * 60 * 24, :month => 60 * 60 * 24 * 30}

    def initialize(job_class)
      @job_class = job_class
    end

    def track
      memory_usage = GetProcessMem.new.mb.round(2)

      job_memory_usage_increx_per(memory_usage, :day)
      job_memory_usage_increx_per(memory_usage, :month)
    end

    def job_memory_usage_increx_per(memory_usage, period)
      total, count, peak, _avg = job_memory_usage_per(period)
      Sidekiq.redis do |conn|
        conn.set(
          self.class.job_memory_usage_period_key(@job_class, period),
          [
            total.to_f + memory_usage,
            count.to_i + 1,
            [peak.to_f, memory_usage].max,
            ((total.to_f + memory_usage)/(count.to_i + 1)).round(2)
          ].to_json)
        conn.expire(self.class.job_memory_usage_period_key(@job_class, period), MEMORY_PERIOD_EXPIRE[period])
      end
    end

    def job_memory_usage_per(period)
      Sidekiq.redis do |conn|
        JSON.parse(conn.get(MemoryUsage.job_memory_usage_period_key(@job_class, period)) || "null")
      end
    end

    def self.job_memory_usage_period_key(job_class, period)
      "#{jobs_memory_usage_key(job_class)}:#{period}:#{Time.now.send(period)}"
    end

    def self.jobs_memory_usage_key(job_class)
      "stats:jobs:#{job_class}:memory_usage"
    end
  end
end

