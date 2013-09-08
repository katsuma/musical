# coding: utf-8
require 'spec_helper'
require 'musical'

describe Musical do
  describe '#setup', fakefs: true do
    subject(:setup) { Musical.setup }
    before { Musical.should_receive(:check_env).and_return(true) }

    context 'when argument `info` is given' do
      before { stub_const('ARGV', ['--info']) }
      it { expect(setup.info).to be_true }
    end

    context 'when argument `ignore-convert-sound` is given' do
      before { stub_const('ARGV', ['--ignore-convert-sound']) }
      it { expect(setup.ignore_convert_sound).to be_true }
    end

    context 'when argument `ignore-use-itunes` is given' do
      before { stub_const('ARGV', ['--ignore-use-itunes']) }
      it { expect(setup.ignore_use_itunes).to be_true }
    end

    context 'when argument `path` is given' do
      before { stub_const('ARGV', ['--path=/dev/foo']) }
      it { expect(setup.path).to eq('/dev/foo') }
    end

    context 'when argument `title` is given' do
      before { stub_const('ARGV', ['--title=new!']) }
      it { expect(setup.title).to eq("new!") }
    end

    context 'when argument `artist` is given' do
      before { stub_const('ARGV', ['--artist=artist!']) }
      it { expect(setup.artist).to eq("artist!") }
    end

    context 'when argument `output` is given' do
      before { stub_const('ARGV', ['--output=/tmp']) }
      it { expect(setup.output).to eq('/tmp') }
    end
  end

  describe '#configuration' do
    subject { Musical.configuration }

    it 'returns a subclass of OpenStruct' do
      expect(subject).to be_an OpenStruct
    end

    it 'includes working directory' do
      expect(subject.working_dir).to eq(File.join(File.expand_path('~'), '.musical'))
    end
  end
end
