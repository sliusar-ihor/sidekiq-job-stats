require_relative 'helpers/stats'
require_relative 'duration'
require_relative 'enqueued'

module SidekiqJobStats
  module WebExtension
    ROOT = File.expand_path('../web', __dir__)

    def self.registered(app)
      app.helpers Helpers::Stats

      app.get '/job_stats' do
        @jobs = SidekiqJobStats::Statistic.find_all.sort

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

        @histories = @job_class.job_histories(@start, @limit)
        @size = @job_class.histories_recorded

        render(:erb, File.read("#{ROOT}/views/job_histories.erb"))
      end
    end
  end
end