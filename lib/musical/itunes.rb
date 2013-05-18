# coding: utf-8

require 'musical/itunes/client'
require 'musical/itunes/track'

module Musical
  module ITunes
    def self.client
      @_client ||= Musical::ITunes::Client.new
    end

    private

    def script_dir

    end
  end
end
