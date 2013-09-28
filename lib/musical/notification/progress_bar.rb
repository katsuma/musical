# coding: utf-8
module Musical
  module Notification
    class ProgressBar < ::ProgressBar
      def self.create(options = {})
        progress_bar = super

        Thread.new do
          while !progress_bar.finished?
            progress_bar.refresh
          end
        end
        progress_bar
      end

    end
  end
end
