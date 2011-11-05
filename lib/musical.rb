require 'rubygems'
require 'trollop'
require 'progressbar'
require 'fileutils'

module Musical
  class DVD
    attr_accessor :opts

    def self.detect
      dev_infos = `df -h | awk {'print $1,$5,$6'}`.split("\n")
      candidates = []
      dev_infos.each do |dev_info|
        info = dev_info.split(" ")
        file_system = info[0]
        capacity = info[1]
        mounted = info[2]
        if capacity == "100%" && mounted.include?("/Volumes")
          candidates << mounted
        end
      end

      raise "Not detect DVD device" if candidates.empty?
      candidates
    end

    def initialize
      @opts = Trollop::options do
        version 'Musical 0.0.1'
        opt :info, "Show your DVD data", :type => :boolean
        opt :ignore_convert_sound, "Rip data only, NOT convert them to wav file", :type => :boolean
        opt :dev, "Set location of DVD device", :default => DVD.detect.first
        opt :title, "Set DVD title", :default => 'LIVE'
        opt :output, "Set location of ripped data", :default => 'ripped'
      end
      run
    end

    def run
      return puts info if @opts[:info]
      rip_by_chapter
      convert_sound unless @opts[:ignore_convert_sound]
    end

    def info
      @_info ||= `dvdbackup --input=#{@opts[:dev]} --info 2>/dev/null`
    end

    def title_with_chapters
      return @_title_chapters unless @_title_chapters.nil?

      @_title_chapters = []
      info_str = info.split("\n")
      info_str.each_with_index do |line, index|
        if line =~ /\s*Title (\d):$/
          @_title_chapters << { :title => $1.to_i, :line => index }
        end
      end

      @_title_chapters.each do |title_chapter|
        line = title_chapter[:line]
        if info_str[line + 1] =~ /\s*Title (\d) has (\d*) chapter/
          title_chapter[:chapter] = $2.to_i
          title_chapter.delete(:line)
        end
      end
      @_title_chapters
    end

    def rip_by_chapter
      puts "Ripping #{title_with_chapters.size} titles, #{chapter_size} chapters to #{@opts[:output]} directory"
      pbar = ProgressBar.new "Ripping", chapter_size
      title_with_chapters.each_with_index do |title_chapter, title_index|
        ripped_dir_base = "#{@opts[:output]}"
        saved_dir = "#{ripped_dir_base}/#{@opts[:title]}/title_#{title_index+1}"
        FileUtils.mkdir_p "#{saved_dir}"

        1.upto title_chapter[:chapter] do |chapter|
          `dvdbackup --name=#{@opts[:title]} --input=#{@opts[:dev]} --title=#{title_index+1} --start=#{chapter} --end=#{chapter} --output=#{ripped_dir_base}_#{title_index}_#{chapter} 2>/dev/null`
          pbar.inc

          # moved file
          vob_path = `find #{ripped_dir_base}_#{title_index}_#{chapter} -name "*.VOB"`.chomp
          FileUtils.mv vob_path, "#{saved_dir}/chapter_#{chapter}.VOB"
          FileUtils.rm_rf "#{ripped_dir_base}_#{title_index}_#{chapter}"
        end
      end
      pbar.finish
    end

    def convert_sound
      puts "Converting #{title_with_chapters.size} titles, #{chapter_size} chapters to #{@opts[:output]} directory"
      pbar = ProgressBar.new "Converting", chapter_size
      title_with_chapters.each_with_index do |title_chapter, title_index|
        ripped_dir_base = "#{@opts[:output]}"
        saved_dir = "#{ripped_dir_base}/#{@opts[:title]}/title_#{title_index+1}"

        1.upto title_chapter[:chapter] do |chapter|
          `ffmpeg -i #{saved_dir}/chapter_#{chapter}.VOB #{saved_dir}/chapter_#{chapter}.wav 2>/dev/null`
          FileUtils.rm_f "#{saved_dir}/chapter_#{chapter}.VOB"
          pbar.inc
        end
      end
      pbar.finish
    end

    def chapter_size
      @_chapter_size ||= title_with_chapters.inject(0){ |count, t| count + t[:chapter]}
    end
    private :chapter_size

  end
end
