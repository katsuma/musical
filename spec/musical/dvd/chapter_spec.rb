# coding: utf-8
require 'spec_helper'
require 'musical'

describe Musical::DVD::Chapter do
  describe '#initialize' do
    subject { described_class.new(vob_path, options) }

    context 'when vob path is not given' do
      let(:vob_path) { nil }
      let(:options) { {} }
      it 'raises an ArgumentError' do
        expect{ subject}.to raise_error(ArgumentError)
      end
    end

    context 'when vob path is given' do
      let(:vob_path) { '/path/to/foo.vob' }
      let(:options) { {} }
      it 'returns an instance of Chapter' do
        expect(subject).to be_a(Musical::DVD::Chapter)
      end
    end
  end

  describe '#to_wav_path' do
    subject { chapter.to_wav_path }

    let(:chapter) { Musical::DVD::Chapter.new(vob_path, chapter_number: 10) }
    let(:vob_path) { '/path/to/foo.vob' }
    let(:wav_path) { "#{Musical.configuration.output}/chapter_#{chapter.chapter_number}.wav" }

    before { chapter.should_receive(:execute_command).with("ffmpeg -i #{vob_path} #{wav_path}", true) }

    it 'returns wav file path which is converted' do
      expect(subject).to eq(wav_path)
    end
  end
end
