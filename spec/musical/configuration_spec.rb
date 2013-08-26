# coding: utf-8
require 'spec_helper'
require 'musical'

describe Musical::Configuration do
  describe '#build' do
    subject { described_class.build(options) }
    let(:options) { { title: 'foo', artist: 'bar' } }

    it 'sets hash data to config class varible as subclass of OpenStruct' do
      subject
      expect(described_class.config).to be_an OpenStruct
      expect(subject.title).to eq('foo')
      expect(subject.artist).to eq('bar')
    end
  end
end
