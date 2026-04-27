require_relative 'helpers/stats'
require_relative 'duration'
require_relative 'enqueued'

module SidekiqJobStats
  module WebExtension
    ROOT = File.expand_path('../web', __dir__)

    STAT_SORT_KEYS = %w[
      name jobs_enqueued jobs_performed_day jobs_performed_month
      job_rolling_avg_day job_rolling_avg_month longest_job_day longest_job_month
      job_memory_usage_avg_day job_memory_usage_avg_month
      peak_memory_usage_day peak_memory_usage_month
    ].freeze

    def self.registered(app)
      app.helpers Helpers::Stats

      app.get '/job_stats' do
        sort_param = respond_to?(:url_params) ? url_params("sort")      : params[:sort]
        dir_param  = respond_to?(:url_params) ? url_params("direction")  : params[:direction]
        @sort      = WebExtension::STAT_SORT_KEYS.include?(sort_param.to_s) ? sort_param.to_s : "name"
        @direction = %w[asc desc].include?(dir_param) ? dir_param : "asc"

        @jobs = SidekiqJobStats::Statistic.find_all
        @jobs.sort! do |a, b|
          av = @sort == "name" ? a.name.to_s : a.send(@sort.to_sym)
          bv = @sort == "name" ? b.name.to_s : b.send(@sort.to_sym)
          result = begin
            Float(av.to_s) <=> Float(bv.to_s)
          rescue ArgumentError, TypeError
            av.to_s <=> bv.to_s
          end
          @direction == "desc" ? -(result || 0) : (result || 0)
        end

        render(:erb, File.read("#{ROOT}/views/job_stats.erb"))
      end

      app.get '/job_stats/job_history/:job_class' do
        klass = route_params(:job_class) || params[:job_class]
        @job_class = SidekiqJobStats::Statistic.find_all.find { |j| j.job_class.to_s == klass }

        @start = 0
        start_param = respond_to?(:url_params) ? url_params("start") : params[:start]
        @start = start_param.to_i if start_param && !start_param.empty?
        @limit = 100
        limit_param = respond_to?(:url_params) ? url_params("limit") : params[:limit]
        @limit = limit_param.to_i if limit_param && !limit_param.empty?

        sort_param     = respond_to?(:url_params) ? url_params("sort")      : params[:sort]
        dir_param      = respond_to?(:url_params) ? url_params("direction")  : params[:direction]
        @sort          = sort_param.to_s
        @direction     = %w[asc desc].include?(dir_param) ? dir_param : "asc"

        @size = @job_class.histories_recorded

        if @sort.empty?
          @histories = @job_class.job_histories(@start, @limit)
        else
          all = @job_class.all_job_histories
          all.sort! do |a, b|
            av, bv = a[@sort], b[@sort]
            result = begin
              Float(av.to_s) <=> Float(bv.to_s)
            rescue ArgumentError
              av.to_s <=> bv.to_s
            end
            @direction == "desc" ? -(result || 0) : (result || 0)
          end
          @histories = all[@start, @limit] || []
        end

        render(:erb, File.read("#{ROOT}/views/job_histories.erb"))
      end
    end
  end
end