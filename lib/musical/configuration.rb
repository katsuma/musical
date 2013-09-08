# coding: utf-8
require 'singleton'

module Musical
  class Configuration < OpenStruct
    include Singleton

    @@config = nil

    def self.build(options)
      @@config = OpenStruct.new(options)
    end

    def self.config
      @@config
    end
  end
end
