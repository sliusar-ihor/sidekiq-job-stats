require 'sidekiq/component'
require_relative 'duration'
require_relative 'enqueued'
require_relative 'memory_usage'

module SidekiqJobStats
  class Middleware
    include Sidekiq::Component

    def call(_worker, msg, queue)
      job_class = msg['class']

      data = {
        enqueued_at: msg['enqueued_at'],
        started_at: Time.now,
        payload: msg['args'],
        status: 'success',
        exception: '',
        queue: queue
      }

      begin
        yield
      rescue StandardError => e
        data[:status] = 'failed'
        data[:exception] = e.message
        raise e
      ensure
        data[:finished_at] = Time.now
        data[:duration] = data[:finished_at] - data[:started_at]

        push_stats(data, job_class)
      end
    end

    private

    def push_stats(data, job_class)
      Duration.new(data, job_class).track
      Enqueued.new(data, job_class).track
      MemoryUsage.new(job_class).track
      History.new(data, job_class).track
    end

    def job_history_key(job_class)
      "stats:jobs:#{job_class}:history"
    end

    def sidekiq_job_class
      @sidekiq_job_class ||= Sidekiq::JobRecord
    end
  end
end
