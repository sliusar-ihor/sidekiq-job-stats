module SidekiqJobStats
  class Duration
    JOB_DURATION_PERIOD_EXPIRE = { :day => 60 * 60 * 24, :month => 60 * 60 * 24 * 30 }

    attr_accessor :job_class

    def initialize(job_class)
      @job_class = job_class
    end

    def track(duration)
      jobs_track_duration(duration, :day)
      jobs_track_duration(duration, :month)
    end

    def jobs_track_duration(duration, period)
      total, count, peak, _avg = jobs_duration_per(period)

      Sidekiq.redis do |conn|
        conn.set(
          jobs_duration_period_key(period),
          [
            total.to_f + duration,
            count.to_i + 1,
            [peak.to_f, duration].max,
            (total.to_f + duration)/(count.to_i + 1)
          ].to_json)
        conn.expire(jobs_duration_period_key(period), JOB_DURATION_PERIOD_EXPIRE[period])
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
        JSON.parse(conn.get(jobs_duration_period_key(period)) || "null")
      end
    end

    def jobs_duration_key
      "stats:jobs:#{job_class}:duration"
    end

    def jobs_duration_period_key(period)
      "#{jobs_duration_key}:#{period}:#{Time.now.send(period)}"
    end
  end
end

