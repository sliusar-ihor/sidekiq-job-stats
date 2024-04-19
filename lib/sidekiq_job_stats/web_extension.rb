require_relative 'helpers/stats'
require_relative 'duration'
require_relative 'enqueued'

module SidekiqJobStats
  module WebExtension
    ROOT = File.expand_path('../web', __dir__)

    def self.registered(app)
      app.helpers Helpers::Stats

      app.get '/history' do
        ApplicantScoringWorker #todo
        @jobs = SidekiqJobStats::Statistic.find_all.sort

        render(:erb, File.read("#{ROOT}/views/job_stats.erb"))
      end

      app.get '/history/job_history/:job_class' do
        ApplicantScoringWorker #todo
        @job_class = SidekiqJobStats::Statistic.find_all.find { |j| j.job_class.to_s == params[:job_class] }

        @start = 0
        @start = params[:start].to_i if params[:start]
        @limit = 100
        @limit = params[:limit].to_i if params[:limit]

        @histories = @job_class.job_histories(@start, @limit)
        @size = @job_class.histories_recorded

        render(:erb, File.read("#{ROOT}/views/job_histories.erb"))
      end

      app.settings.locales << File.expand_path('locales', ROOT)
    end
  end
end