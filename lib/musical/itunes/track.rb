# coding: utf-8
module Musical
  module ITunes
    class Track
      include Musical::Util

      attr_accessor :persistent_id, :name, :album, :artist, :track_count, :track_number

      def initialize(persistent_id)
        raise ArgumentError.new 'persistent_id should be specified' unless persistent_id
        @persistent_id = persistent_id
      end

      def convert
        converted_persistent_id = execute_script('track/convert.scpt', @persistent_id)
        Track.new(converted_persistent_id)
      end

      def delete!
        execute_script('track/delete.scpt', @persistent_id)
        @persistent_id = nil
      end

      def update_attribute!(attributes)
      end

    end
  end
end
