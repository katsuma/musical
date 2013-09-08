# coding: utf-8
require 'spec_helper'
require 'musical'

describe Musical::DVD::Wav do
  describe '#delete!' do
    subject { wav.delete! }
    let!(:wav) do
      FileUtils.touch(wav_path)
      described_class.new(wav_path)
    end
    let(:wav_path) { '/tmp/foo.wav' }

    it 'deletes original file', faksefs: true do
      expect { subject }.to change { File.exist?(wav_path) }.from(true).to(false)
    end
  end
end
