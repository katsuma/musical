# coding: utf-8
module Musical
  module Util
    REQUIRED_APPS = %w(dvdbackup ffmpeg).freeze

    def check_env
      REQUIRED_APPS.each do |app|
        unless installed?(app)
          messages = []
          messages << "'#{app}' is not installed."
          messages << "Try this command to install '#{app}'."
          messages << ""
          messages << "   brew install #{app}"
          messages << ""
          raise RuntimeError, messages.join("\n")
        end
      end
      true
    end

    def installed?(app)
      execute_out, process_status = *Open3.capture2("which #{app}")
      !execute_out.empty?
    end
  end
end
