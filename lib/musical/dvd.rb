# coding: utf-8
require 'singleton'

module Musical
  class DVD
    include Singleton
    include Musical::Util
    extend Musical::Util

    attr_accessor :title, :artist

    @@dev = nil

    def self.detect
      drutil_out = execute_command('drutil status')

      raise RuntimeError.new 'DVD drive is not found' unless drutil_out
      raise RuntimeError.new 'DVD is not inserted'   unless drutil_out.include?('Name:')

      file_system = drutil_out.split("\n").select do |line|
        line.include?('Name:')
      end.first.match(/Name: (.+)/)[1]

      df_out = execute_command('df -H -a')
      df_out.split("\n").select do |line|
        line.include?(file_system)
      end.first.gsub(/( ){2,}+/, "\t").split("\t").last
    end

    def self.dev=(dev)
      @@dev = dev
    end

    def self.dev
      @@dev
    end

    def self.load(options = {})
      unless @@dev
        @@dev = options[:dev] || self.detect
      end

      dvd = DVD.instance
      dvd.title = options[:title] if options[:title]
      dvd.artist = options[:artist] if options[:artist]

      if block_given?
        yield(dvd)
      end
    end

    def info
      raise RuntimeError.new 'Not detect DVD' unless @@dev
      @info ||= execute_command("dvdbackup --input='#{@@dev}'", true)
    end

    def title_sets
      return @sets if @sets

      @sets = []
      sets_regexp = /\s*Title (\d) has (\d*) chapter/
      info.split("\n").each do |line|
        if line =~ sets_regexp
          @sets << { title: $1.to_i, chapter: $2.to_i }
        end
      end
      @sets
    end

    def rip
    end
  end
end
