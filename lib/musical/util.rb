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
      !!(system "which #{app}")
    end

    def execute_sctipt(script_path, args='')
      execute_out, process_status = *Open3.capture2("osascript #{script_base_dir}/#{script_path} #{args}")
      execute_out
    end

    def script_base_dir
      File.expand_path("#{File.dirname(__FILE__)}/../../scripts")
    end
  end
end
