module SidekiqJobStats
  class Duration
    JOB_DURATION_PERIOD_EXPIRE = { :day => 60 * 60 * 24, :month => 60 * 60 * 24 * 30 }

    def initialize(job_data, job_class)
      @job_data = job_data
      @job_class = job_class
    end

    def track
      jobs_track_duration(@job_data[:duration], :day)
      jobs_track_duration(@job_data[:duration], :month)
    end

    def jobs_track_duration(duration, period)
      total, count, peak, _avg = jobs_duration_per(period)

      Sidekiq.redis do |conn|
        conn.set(
          self.class.jobs_duration_period_key(@job_class, period),
          [
            total.to_f + duration,
            count.to_i + 1,
            [peak.to_f, duration].max,
            (total.to_f + duration)/(count.to_i + 1)
          ].to_json)
        conn.expire(self.class.jobs_duration_period_key(@job_class, period), JOB_DURATION_PERIOD_EXPIRE[period])
      end
    end

    def jobs_duration_per(period)
      Sidekiq.redis do |conn|
        JSON.parse(conn.get(Duration.jobs_duration_period_key(@job_class, period)) || "null")
      end
    end

    def self.jobs_duration_key(job_class)
      "stats:jobs:#{job_class}:duration"
    end

    def self.jobs_duration_period_key(job_class, period)
      "#{jobs_duration_key(job_class)}:#{period}:#{Time.now.send(period)}"
    end
  end
end

