module SidekiqJobStats
  class Statistic

    DEFAULT_STATS = [:jobs_enqueued, :jobs_performed_day, :jobs_performed_month,
                     :job_rolling_avg_day, :job_rolling_avg_month,
                     :longest_job_day, :longest_job_month, :job_memory_usage_avg_day,
                     :job_memory_usage_avg_month, :peak_memory_usage_day,
                     :peak_memory_usage_month]

    attr_accessor :job_class

    def self.find_all
      all_jobs_classes.map{|j| new(j)}
    end

    def self.all_jobs_classes
      subclasses = []
      ObjectSpace.each_object(Class) do |sub_class|
        next unless sub_class < Sidekiq::Worker
        subclasses << sub_class
      end
      subclasses
    end

    def initialize(job_class)
      self.job_class = job_class
    end

    def jobs_enqueued
      Sidekiq.redis do |conn|
        conn.get(Enqueued.job_stats_enqueued_key(job_class)).to_i
      end
    end

    def jobs_performed_day
      _total, count, _peak, _avg = jobs_duration_per(:day)
      count
    end

    def jobs_performed_month
      _total, count, _peak, _avg = jobs_duration_per(:month)
      count
    end

    def job_rolling_avg_day
      _total, _count, _peak, avg = jobs_duration_per(:day)
      avg
    end

    def job_rolling_avg_month
      _total, _count, _peak, avg = jobs_duration_per(:month)
      avg
    end

    def longest_job_day
      _total, _count, peak, _avg = jobs_duration_per(:day)
      peak
    end

    def longest_job_month
      _total, _count, peak, _avg = jobs_duration_per(:month)
      peak
    end

    def jobs_duration_per(period)
      Sidekiq.redis do |conn|
        JSON.parse(conn.get(Duration.jobs_duration_period_key(job_class, period)) || "null")
      end
    end

    def job_memory_usage_per(period)
      Sidekiq.redis do |conn|
        JSON.parse(conn.get(MemoryUsage.job_memory_usage_period_key(job_class, period)) || "null")
      end
    end

    def job_memory_usage_avg_day
      _total, _count, _peak, avg = job_memory_usage_per(:day)
      avg
    end

    def job_memory_usage_avg_month
      _total, _count, _peak, avg = job_memory_usage_per(:month)
      avg
    end

    def peak_memory_usage_day
      _total, _count, peak, _avg = job_memory_usage_per(:day)
      peak
    end

    def peak_memory_usage_month
      _total, _count, peak, _avg = job_memory_usage_per(:month)
      peak
    end

    def job_histories(start = 0, limit = 100)
      Sidekiq.redis do |conn|
        conn.lrange(History.job_history_key(job_class), start, start + limit - 1).map { |h| JSON.parse(h) }
      end
    end

    def histories_recorded
      Sidekiq.redis do |conn|
        conn.llen(History.job_history_key(job_class))
      end
    end

    def name
      self.job_class.name
    end

    def <=>(other)
      self.name <=> other.name
    end
  end
end
