# coding: utf-8
require 'spec_helper'
require 'musical'

describe Musical::ITunes::Track do
  let(:persistent_id) { '4154EB8B839D53C2' }

  describe '#initialize' do
    context 'when persistent_id is not given' do
      it { expect { described_class.new }.to raise_error(ArgumentError) }
    end

    context 'when persistent_id is not given' do
      subject { described_class.new(persistent_id) }
      it { should be_a(described_class)  }
    end
  end

  describe '#convert' do
    subject(:convert) { track.convert }
    let(:track) { described_class.new(persistent_id) }
    before do
      converted_persistent_id = '4154EB8B839D53C3'
      track.should_receive(:execute_script).
        with('track/convert.scpt', persistent_id).
        and_return(converted_persistent_id)
    end

    it 'returns a new instance which is converted track' do
      converted_track = convert
      converted_track.should be_a(described_class)
      converted_track.persistent_id.should_not == track.persistent_id
    end
  end

  describe '#delete' do
    subject(:delete) { track.delete }
    let(:track) { described_class.new(persistent_id) }
    it 'deletes a track' do
      track.should_receive(:execute_script).with('track/delete.scpt', persistent_id)
      delete
    end
  end
end
