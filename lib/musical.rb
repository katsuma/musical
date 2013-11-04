require 'trollop'
require 'ruby-progressbar'
require 'fileutils'
require 'open3'
require 'ostruct'
require 'itunes-client'

require 'musical/configuration'
require 'musical/util'
require 'musical/version'
require 'musical/dvd'
require 'musical/dvd/chapter'
require 'musical/dvd/wav'
require 'musical/notification/progress_bar'

module Musical
  extend Musical::Util

  def configuration
    Configuration.config || Musical.setup
  end
  module_function :configuration

  def setup
    return unless check_env

    # init working directory
    working_dir = File.join(File.expand_path('~'), '.musical')
    FileUtils.mkdir_p(working_dir) unless File.exist?(working_dir)

    # parse options
    options = Trollop::options do
      version "musical #{Musical::VERSION}"
      opt :info, "Show your DVD data", type: :boolean
      opt :ignore_convert_sound, "Rip data only, NOT convert them to wav file", type: :boolean
      opt :ignore_use_itunes, "NOT add ripped files to iTunes and encode them", type: :boolean
      opt :path, "Set device path of DVD", type: :string
      opt :title, "Set DVD title", type: :string, default: 'LIVE'
      opt :artist, "Set DVD artist", type: :string, default: 'Artist'
      opt :year, "Set year DVD was recorded", type: :int, default: Time.now.year
      opt :output, "Set location of ripped data", type: :string, default: 'ripped'
    end

    configuration = Configuration.build(options.merge(working_dir: working_dir))
    yield(configuration) if block_given?

    configuration
  end
  module_function :setup
end
