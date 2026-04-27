module SidekiqJobStats
  module Helpers
    module Stats
      def stat_header(stat_name)
        label = stat_name.to_s.gsub(/_/, " ").capitalize
        job_stats_sort_th(label, stat_name.to_s)
      end

      def job_stats_sort_th(label, key)
        dir = (@sort == key && @direction == "asc") ? "desc" : "asc"
        css = @sort == key ? "sort-#{@direction}" : ""
        url = "#{root_path}job_stats?sort=#{key}&direction=#{dir}"
        "<th class='#{css}'><a href='#{url}'>#{label}</a></th>"
      end

      def display_stat(stat, stat_name, format)
        formatted_stat =   self.send(format, stat.send(stat_name))
        "<td>#{formatted_stat}</td>"
      end

      def time_display(float)
        float.blank? ? "" : ("%.2f" % float.to_s) + "s"
      end

      def number_display(num)
        num.blank? ? "" : num
      end

      def mb_display(num)
        num.blank? ? "" : "#{num}MB"
      end

      # Sidekiq 6/7 stores enqueued_at as seconds (~1.7e9).
      # Sidekiq 8+ stores it as milliseconds (~1.7e12).
      def format_enqueued_at(value)
        return "" unless value
        ts = value.to_f
        return value if ts.zero?
        ts /= 1000.0 if ts > 1_000_000_000_000
        Time.at(ts)
      end
    end
  end
end
