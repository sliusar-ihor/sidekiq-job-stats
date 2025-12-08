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
        klass = params[:job_class] || route_params(:job_class)
        @job_class = SidekiqJobStats::Statistic.find_all.find { |j| j.job_class.to_s == klass }
        
        @start = 0
        @start = params[:start].to_i if params[:start]
        @limit = 100
        @limit = params[:limit].to_i if params[:limit]

        @histories = @job_class.job_histories(@start, @limit)
        @size = @job_class.histories_recorded

        render(:erb, File.read("#{ROOT}/views/job_histories.erb"))
      end
    end
  end
end