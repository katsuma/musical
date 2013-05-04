# coding: utf-8
require 'spec_helper'
require 'musical'

describe Musical::Util do
  class DummyClass
    include Musical::Util
  end
  let!(:klass) { DummyClass.new }

  describe '#check_env' do
    subject(:check_env) { klass.check_env }

    context 'when app is not installed' do
      before do
        klass.should_receive(:installed?).and_return(false)
      end

      it 'raises a RuntimeError' do
        expect { check_env }.to raise_error(RuntimeError)
      end
    end

    context 'when app is installed' do
      before do
        klass.should_receive(:installed?).twice.and_return(true)
      end

      it { should be_true }
    end
  end

  describe 'installed?' do
    subject { klass.installed?(app)  }
    let(:app) { 'dvdbackup' }

    context 'when app is not installed' do
      before do
        klass.should_receive(:system).with("which #{app}").and_return(false)
      end
      it { should be_false }
    end

    context 'when spp is installed' do
      before do
        klass.should_receive(:system).with("which #{app}").and_return(true)
      end
      it { should be_true }
    end
  end
end
