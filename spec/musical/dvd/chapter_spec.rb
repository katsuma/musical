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
        expect{ subject }.to raise_error(ArgumentError)
      end
    end

    context 'when vob path is given' do
      let(:vob_path) { '/path/to/foo.vob' }
      let(:options) { { chapter_number: 3 } }
      it 'returns an instance of Chapter' do
        expect(subject).to be_a(described_class)
        expect(subject.chapter_number).to eq(3)
      end
    end
  end

  describe '#to_wav' do
    subject { chapter.to_wav(wav_path) }

    let(:chapter) { described_class.new(vob_path, chapter_number: 10) }
    let(:vob_path) { '/path/to/foo.vob' }
    let(:wav_path) { '/tmp/foo.wav' }

    before do
      chapter.should_receive(:execute_command).
        with("ffmpeg -i #{vob_path} -ac 2 #{wav_path}", true).
        and_return(FileUtils.touch(wav_path))
    end

    after { subject.delete! }

    it 'returns wav file which is converted', fakefs: true do
      expect(subject).to be_a(Musical::DVD::Wav)
      expect(subject.path).to eq(wav_path)
    end
  end
end
