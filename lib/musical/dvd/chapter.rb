# coding: utf-8
module Musical
  class DVD::Chapter
    include Musical::Util

    attr_accessor :vob_path, :name, :chapter_number

    DEFAULT_CHAPTER_NUMBER = 1
    DEFAULT_CHAPTER_NAME = 'default chapter name'

    def initialize(vob_path, options = {})
      raise ArgumentError.new 'VOB path is not given' if vob_path.nil?

      @vob_path = vob_path
      @name = options[:name] || DEFAULT_CHAPTER_NAME
      @chapter_number = options[:chpter_number] || DEFAULT_CHAPTER_NUMBER
    end

    def wav_path
      return @wav_path if @wav_path

      save_dir = Musical.configuration.output
      @wav_path = "#{save_dir}/chapter_#{@chapter_number}.wav"

      command = "ffmpeg -i #{@vob_path} #{@wav_path}"
      execute_command(command, true)
      @wav_path
    end

    def delete_wav
      FileUtils.rm_f(wav_path) if wav_path
    end
  end
end
