# coding: utf-8
require 'spec_helper'
require 'musical'

describe Musical do
  describe '#setup' do
    subject(:setup) { Musical.setup }
    before { Musical.should_receive(:check_env).and_return(true) }

    context 'when argument `info` is given' do
      before { stub_const('ARGV', ['--info']) }
      it { setup[:info].should be_true }
    end

    context 'when argument `ignore-convert-sound` is given' do
      before { stub_const('ARGV', ['--ignore-convert-sound']) }
      it { setup[:ignore_convert_sound].should be_true }
    end

    context 'when argument `ignore-use-itunes` is given' do
      before { stub_const('ARGV', ['--ignore-use-itunes']) }
      it { setup[:ignore_use_itunes].should be_true }
    end

    context 'when argument `dev` is given' do
      before { stub_const('ARGV', ['--dev=/dev/foo']) }
      it { setup[:dev].should == '/dev/foo' }
    end

    context 'when argument `title` is given' do
      context 'if argument includes a space' do
        before { stub_const('ARGV', ['--title="new title"']) }
        it { setup[:title].should == "new_title" }
      end

      context 'if argument does not include a space' do
        before { stub_const('ARGV', ['--title=new!']) }
        it { setup[:title].should == "new!" }
      end
    end

    context 'when argument `artist` is given' do
      context 'if argument includes a space' do
        before { stub_const('ARGV', ['--artist="new artist"']) }
        it { setup[:artist].should == "new_artist" }
      end

      context 'if argument does not include a space' do
        before { stub_const('ARGV', ['--artist=artist!']) }
        it { setup[:artist].should == "artist!" }
      end
    end

    context 'when argument `output` is given' do
      before { stub_const('ARGV', ['--output=/tmp']) }
      it { setup[:output].should == '/tmp' }
    end
  end
end
