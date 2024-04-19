require 'sidekiq/component'
require_relative 'duration'
require_relative 'enqueued'
require_relative 'memory_usage'

module SidekiqJobStats
  class Middleware
    include Sidekiq::Component

    def call(_worker, msg, queue)
      data = {
        enqueued_at: msg['enqueued_at'], started_at: Time.now, payload: msg['args'], status: 'success',
        exception: '', queue: queue
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
        push_stats(data, msg['class'])
      end
    end

    private

    def push_stats(data, job_class)
      Duration.new(job_class).track(data[:duration])
      Enqueued.new(job_class).track
      MemoryUsage.new(job_class).track
      History.new(job_class).track(data)
    end

    def sidekiq_job_class
      @sidekiq_job_class ||= Sidekiq::JobRecord
    end
  end
end
