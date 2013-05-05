require 'trollop'
require 'progressbar'
require 'fileutils'
require 'open3'

require 'musical/util'
require 'musical/dvd'

module Musical
  extend Musical::Util

  def setup
    return unless check_env

    version = open(File.join(File.dirname(__FILE__), "..", "VERSION")){ |f| f.gets }

    # parse options
    opts = Trollop::options do
      version "Musical #{version}"
      opt :info, "Show your DVD data", :type => :boolean
      opt :ignore_convert_sound, "Rip data only, NOT convert them to wav file", :type => :boolean
      opt :ignore_use_itunes, "NOT add ripped files to iTunes and encode them", :type => :boolean
      opt :dev, "Set location of DVD device", :type => :string
      opt :title, "Set DVD title", :type => :string, :default => 'LIVE'
      opt :artist, "Set DVD artist", :type => :string, :default => 'Artist'
      opt :output, "Set location of ripped data", :type => :string, :default => 'ripped'
    end

    # for dvdbackup
    opts[:title] = opts[:title].gsub(" ", "_").gsub("\"", '').gsub("\'", '')
    opts[:artist] = opts[:artist].gsub(" ", "_").gsub("\"", '').gsub("\'", '')

    opts
  end
  module_function :setup
end
