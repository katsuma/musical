# coding: utf-8
module Musical
  class DVD::Chapter
    include Musical::Util

    attr_accessor :vob_path, :name, :chapter_number

    DEFAULT_CHAPTER_NUMBER = 1
    DEFAULT_CHAPTER_NAME = 'default chapter name'
    DEFAULT_TITLE_NUMBER = 1

    def initialize(vob_path, options = {})
      raise ArgumentError.new 'VOB path is not given' if vob_path.nil?

      @vob_path = vob_path
      @name = options[:name] || DEFAULT_CHAPTER_NAME
      @chapter_number = options[:chapter_number] || DEFAULT_CHAPTER_NUMBER
      @title_number = options[:title_number] || DEFAULT_TITLE_NUMBER
    end

    def to_wav(wav_path = "#{Musical.configuration.output}/chapter_#{@title_number}_#{@chapter_number}.wav")
      return @wav if @wav

      command = "ffmpeg -i #{@vob_path} -ac 2 #{wav_path}"
      execute_command(command, true)
      DVD::Wav.new(wav_path)
    end
  end
end
