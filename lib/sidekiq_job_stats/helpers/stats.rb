module SidekiqJobStats
  module Helpers
    module Stats
      def stat_header(stat_name)
        "<th class='header'>" + stat_name.to_s.gsub(/_/,' ').capitalize + "</th>"
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
    end
  end
end
