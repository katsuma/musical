require 'rubygems'
require 'trollop'
require 'progressbar'
require 'fileutils'
require 'appscript'
require 'rbconfig'

require 'musical/dvd'
require 'musical/itunes'

module Musical
  def setup
    # check env
    ['dvdbackup', 'ffmpeg'].each do |app|
      if `which #{app}`.empty?
        raise RuntimeError, "\n\n'#{app}' is not installed.\n\ntry:\n  brew install #{app}\n\n"
      end
    end

    version = open(File.join(File.dirname(__FILE__), "..", "VERSION")){ |f| f.gets }

    # parse options
    opts = Trollop::options do
      version "Musical #{version}"
      opt :info, "Show your DVD data", :type => :boolean
      opt :ignore_convert_sound, "Rip data only, NOT convert them to wav file", :type => :boolean
      opt :ignore_use_itunes, "NOT add ripped files to iTunes and encode them", :type => :boolean
      opt :dev, "Set location of DVD device"
      opt :title, "Set DVD title", :default => 'LIVE'
      opt :artist, "Set DVD artist", :default => 'Artist'
      opt :output, "Set location of ripped data", :default => 'ripped'
    end

    # fix fox dvdbackup
    opts[:trim_title] = opts[:title].gsub(" ", "_")
    opts[:trim_artist] = opts[:artist].gsub(" ", "_")

    opts
  end

end
