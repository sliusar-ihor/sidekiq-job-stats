module SidekiqJobStats
  class Statistic

    # DEFAULT_STATS = [:jobs_enqueued, :jobs_performed_day, :jobs_performed_month,
    #                  :job_rolling_avg_day, :job_rolling_avg_month,
    #                  :longest_job_day, :longest_job_month, :job_memory_usage_avg_day,
    #                  :job_memory_usage_avg_month, :peak_memory_usage_day,
    #                  :peak_memory_usage_month]

    attr_accessor :job_class

    delegate :jobs_enqueued, to: :enqueued
    delegate :jobs_performed_day, :jobs_performed_month, :job_rolling_avg_day, :job_rolling_avg_month,
      :longest_job_day, :longest_job_month, to: :duration
    delegate :job_memory_usage_avg_day, :job_memory_usage_avg_month, :peak_memory_usage_day,
             :peak_memory_usage_month, to: :memory_usage
    delegate :job_histories, :histories_recorded, to: :history
    delegate :name, to: :job_class

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

    def <=>(other)
      self.name <=> other.name
    end

    %w[duration memory_usage history enqueued].each do |method_name|
      define_method(method_name) do
        instance_variable_get("@#{method_name}") ||
          instance_variable_set("@#{method_name}", Object.const_get("SidekiqJobStats::" + method_name.camelize).new(job_class))
      end
    end
  end
end
