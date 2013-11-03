# coding: utf-8
module Musical
  module Notification
    class ProgressBar < ::ProgressBar
      FORMAT = '%a %B %p%% %t'

      def self.create(options = {})
        options = { format: FORMAT }.merge(options)
        progress_bar = super(options)

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
