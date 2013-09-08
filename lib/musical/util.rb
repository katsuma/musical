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
      !execute_command("which #{app}").empty?
    end

    def execute_command(cmd, silent = false)
      cmd << ' 2>/dev/null' if silent
      execute_out, _ = *Open3.capture2(cmd)
      execute_out
    end
  end
end
