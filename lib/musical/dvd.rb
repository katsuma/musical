# coding: utf-8
require 'singleton'

module Musical
  class DVD
    include Singleton
    include Musical::Util
    extend Musical::Util

    attr_accessor :title, :artist

    @@path = nil

    DETECT_ERROR_MESSAGE = 'Not detect DVD, Try `DVD.load` and check your drive device path.'
    DRIVE_NOT_FOUND_MESSAGE = 'DVD drive is not found.'
    DVD_NOT_INSERTED_MESSAGE = 'DVD is not inserted.'

    def self.detect
      drutil_out = execute_command('drutil status')

      raise RuntimeError.new DRIVE_NOT_FOUND_MESSAGE  unless drutil_out
      raise RuntimeError.new DVD_NOT_INSERTED_MESSAGE unless drutil_out.include?('Name:')

      file_system = drutil_out.split("\n").select do |line|
        line.include?('Name:')
      end.first.match(/Name: (.+)/)[1]
    end

    def self.path=(path)
      @@path = path
    end

    def self.path
      @@path
    end

    def self.load(options = {})
      if @@path.nil? || options[:forcibly]
        @@path = options[:path] || self.detect
      end

      dvd = DVD.instance
      dvd.title = options[:title] || Musical.configuration.title
      dvd.artist = options[:artist] || Musical.configuration.artist

      if block_given?
        yield(dvd)
      end

      dvd.info
    end

    def info
      raise RuntimeError.new DETECT_ERROR_MESSAGE unless @@path

      return @info if @info

      @info = execute_command("dvdbackup --info --input='#{@@path}'", true)
      raise RuntimeError.new DETECT_ERROR_MESSAGE if @info.empty?
      @info
    end

    def title_sets
      return @title_sets if @title_sets

      @title_sets = [].tap do |sets|
        sets_regexp = /\s*Title (\d) has (\d*) chapter/
        info.split("\n").each do |line|
          if line =~ sets_regexp
            sets << { title: $1.to_i, chapter: $2.to_i }
          end
        end
      end
    end

    def vob_path
      find_command = "find '#{Musical.configuration.working_dir}' -name '*.VOB'"
      execute_command(find_command).split("\n").first
    end
    private :vob_path

    def rip
      raise RuntimeError.new DETECT_ERROR_MESSAGE unless @@path
      save_dir = Musical.configuration.output
      FileUtils.mkdir_p save_dir

      chapter_size = title_sets.inject(0){ |size, set| size + set[:chapter] }
      progress_bar = ProgressBar.create(title: 'Ripping', total: chapter_size, format: '%a %B %p%% %t')
      chapters = []

      title_sets.each do |title_set|
        chapters << (1..title_set[:chapter]).map do |chapter_index|
          commands = []
          commands << 'dvdbackup'
          commands << "--input='#{@@path}'"
          commands << "--title='#{title_set[:title]}'"
          commands << "--start=#{chapter_index}"
          commands << "--end=#{chapter_index}"
          commands << "--output='#{Musical.configuration.working_dir}'"
          execute_command(commands.join(' '), true)

          progress_bar.increment

          vob_save_path = "#{save_dir}/TITLE_#{title_set[:title]}_#{chapter_index}.VOB"
          FileUtils.mv(vob_path, vob_save_path)
          Chapter.new(vob_save_path, title_number: title_set[:title], chapter_number: chapter_index)
        end
      end
      chapters.flatten
    end
  end
end
