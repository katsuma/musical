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
        klass.should_receive(:execute_command).with("which #{app}").and_return('')
      end
      it { should be_false }
    end

    context 'when spp is installed' do
      before do
        klass.should_receive(:execute_command).with("which #{app}").and_return('/path/to/app')
      end
      it { should be_true }
    end
  end

  describe '#execute_command' do
    let(:cmd) { 'which app' }
    let(:path) { '/path/to/app' }

    context 'when silent options is not given' do
      subject { klass.execute_command(cmd) }
      before { Open3.should_receive(:capture2).with(cmd).and_return(path) }
      it { expect(subject).to eq(path) }
    end

    context 'when silent option is given' do
      subject { klass.execute_command(cmd, true) }
      before { Open3.should_receive(:capture2).with("#{cmd} 2>/dev/null").and_return(path) }
      it { expect(subject).to eq(path) }
    end
  end
end
