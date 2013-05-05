# coding: utf-8
module Musical
  class DVD
    attr_accessor :opts

    def self.detect
      drutil_out, process_status = *Open3.capture2('drutil status')

      raise RuntimeError.new 'DVD drive is not found' unless drutil_out
      raise RuntimeError.new 'DVD is not inserted'   unless drutil_out.include?('Name:')

      file_system = drutil_out.split("\n").select do |line|
        line.include?('Name:')
      end.first.match(/Name: (.+)/)[1]

      df_out, process_status = *Open3.capture2('df -H -a')
      df_out.split("\n").select do |line|
        line.include?(file_system)
      end.first.gsub(/( ){2,}+/, "\t").split("\t").last
    end

    def initialize(options={})
      @opts = options

      return puts info if @opts[:info]

      rip_by_chapter
      convert_sound unless @opts[:ignore_convert_sound]
      to_itunes unless @opts[:ignore_use_itunes]
    end

    def dev
      @_dev ||= DVD.detect.first
    end

    def info
      raise "Not detect DVD device" if dev.empty?
      @_info ||= `dvdbackup --input='#{dev}' --info 2>/dev/null`
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
      task_message "Ripping"

      pbar = ProgressBar.new "Ripping", chapter_size
      title_with_chapters.each_with_index do |title_chapter, title_index|
        ripped_dir_base = "#{@opts[:output]}"
        saved_dir = "#{ripped_dir_base}/#{@opts[:trim_title]}/title_#{title_index+1}"
        FileUtils.mkdir_p "#{saved_dir}"

        1.upto title_chapter[:chapter] do |chapter|
          `dvdbackup --name=#{@opts[:trim_title]} --input='#{dev}' --title=#{title_index+1} --start=#{chapter} --end=#{chapter} --output='#{ripped_dir_base}_#{title_index}_#{chapter}' 2>/dev/null`
          pbar.inc
          # moved file
          vob_path = `find '#{ripped_dir_base}_#{title_index}_#{chapter}' -name "*.VOB"`.chomp
          vob_path.split.each do |vob|
            FileUtils.mv vob, "#{saved_dir}/chapter_#{chapter}.VOB"
          end
          FileUtils.rm_rf "#{ripped_dir_base}_#{title_index}_#{chapter}"
        end
      end
      pbar.finish
    end

    def convert_sound
      task_message "Converting"

      pbar = ProgressBar.new "Converting", chapter_size
      title_with_chapters.each_with_index do |title_chapter, title_index|
        ripped_dir_base = "#{@opts[:output]}"
        saved_dir = "#{ripped_dir_base}/#{@opts[:trim_title]}/title_#{title_index+1}"

        1.upto title_chapter[:chapter] do |chapter|
          `ffmpeg -i #{saved_dir}/chapter_#{chapter}.VOB #{saved_dir}/chapter_#{chapter}.wav 2>/dev/null`
          FileUtils.rm_f "#{saved_dir}/chapter_#{chapter}.VOB"
          pbar.inc
        end
      end
      pbar.finish
    end

    def to_itunes
      task_message "To iTunes"

      pbar = ProgressBar.new "To iTunes", chapter_size
      its = ITunes.new

      title_with_chapters.each_with_index do |title_chapter, title_index|
        ripped_dir_base = "#{@opts[:output]}"
        saved_dir = "#{ripped_dir_base}/#{@opts[:trim_title]}/title_#{title_index+1}"

        options = { :album => @opts[:title], :artist => @opts[:artist], :track_count => title_chapter[:chapter]}
        1.upto title_chapter[:chapter] do |chapter|
          its.add("#{saved_dir}/chapter_#{chapter}.wav", options.merge(:track_number => chapter))
          pbar.inc
        end
      end
      FileUtils.rm_rf @opts[:output]
      pbar.finish
    end

    def chapter_size
      @_chapter_size ||= title_with_chapters.inject(0){ |count, t| count + t[:chapter]}
    end
    private :chapter_size

    def task_message(task)
      raise "Not found any titles and chapters" if title_with_chapters.size == 0 && chapter_size == 0
      puts "#{task} #{title_with_chapters.size} titles, #{chapter_size} chapters"
    end
    private :task_message

  end
end
