module Musical
  include Appscript

  class ITunes
    attr_accessor :opts
    def initialize(options = {})
      raise "iTunes support works on only Mac OSX" unless RUBY_PLATFORM.include? "darwin"
      @opts = options # not used yet
    end

    def its
      @_its ||= app "iTunes.app"
    end

    def add(file_path, options = {})
      wav = its.add MacTypes::FileURL.path(File.expand_path(file_path))
      return if wav.nil?

      tracks = wav.convert
      sleep 5 # FIXME
      tracks.each do |track|
        [:name, :album, :artist, :track_count, :track_number].each do |key|
          unless options[key].nil?
            track.send(key).set options[key]
          end
        end
      end
      its.delete wav
    end
  end
end
