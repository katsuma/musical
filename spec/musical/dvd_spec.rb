# coding: utf-8
require 'spec_helper'
require 'musical'

include Musical

describe DVD do
  describe '.detect' do
    subject(:detect) { DVD.detect }
    let(:drutil) { 'drutil status' }

    context 'when DVD drive is not found' do
      before do
        DVD.should_receive(:execute_command).with(drutil).and_return('')
      end

      it 'raises a RuntimeError' do
        expect { detect }.to raise_error(RuntimeError)
      end
    end

    context 'when DVD is not inserted' do
      let(:drutil_out) do
        <<"EOM"
Vendor   Product           Rev
MATSHITA DVD-R   UJ-85J    FM0S

Type: No Media Inserted
EOM
      end
      before { DVD.should_receive(:execute_command).with(drutil).and_return(drutil_out) }

      it 'raises a RuntimeError' do
        expect { detect }.to raise_error(RuntimeError)
      end
    end

    context 'when DVD is inserted' do
      let(:drutil_out) do
        <<"EOM"
 Vendor   Product           Rev
 MATSHITA DVD-R   UJ-85J    FM0S

           Type: DVD-ROM              Name: /dev/disk3
       Sessions: 1                  Tracks: 1
   Overwritable:   00:00:00         blocks:        0 /   0.00MB /   0.00MiB
     Space Free:   00:00:00         blocks:        0 /   0.00MB /   0.00MiB
     Space Used:  787:56:00         blocks:  3545700 /   7.26GB /   6.76GiB
    Writability:
      Book Type: DVD-ROM (v1)
EOM
      end

      let(:df) { 'df -H -a' }
      let(:df_out) do
        <<"EOM"
Filesystem       Size   Used  Avail Capacity    iused     ifree %iused  Mounted on
/dev/disk0s2     999G   282G   717G    29%   68837522 175143220   28%   /
devfs            189k   189k     0B   100%        639         0  100%   /dev
map -hosts         0B     0B     0B   100%          0         0  100%   /net
map auto_home      0B     0B     0B   100%          0         0  100%   /home
/dev/disk3       7.3G   7.3G     0B   100% 18446744073706006195   3545437 115292150460662546432%   /Volumes/DVD_VIDEO
EOM
      end
      before do
        DVD.should_receive(:execute_command).with(drutil).and_return(drutil_out)
        DVD.should_receive(:execute_command).with(df).and_return(df_out)
      end

      it { should == '/Volumes/DVD_VIDEO'}
    end
  end

  describe '.dev' do
    subject { DVD.dev }
    context 'dev class property is not set' do
      it 'returns nil' do
        expect(subject).to eq(nil)
      end
    end

    context 'dev class property is set' do
      before{ DVD.dev = '/dev/path' }
      it 'returns property value' do
        expect(subject).to eq('/dev/path')
      end
    end
  end

  describe '.load' do
    before { DVD.dev = nil }

    context 'when options are not given' do
      subject { DVD.load }

      context 'and if dev path is set' do
        before { DVD.dev = '/dev/some/path' }

        it 'does not call DVD.detect' do
          DVD.should_not_receive(:detect)
          subject
        end
      end

      context 'and if dev path is not set' do
        it 'sets dev path by DVD.detect' do
          DVD.should_receive(:detect).and_return('/dev/some/path')
          subject
          expect(DVD.dev).to eq('/dev/some/path')
        end
      end
    end

    context 'when options are given' do
      subject { DVD.load(options) }
      let(:options) { { dev: '/dev/path', title: 'some title' } }

      it 'sets dev path by given option' do
        subject
        expect(DVD.dev).to eq('/dev/path')
      end

      it 'sets title by given option' do
        subject
        expect(DVD.instance.title).to eq('some title')
      end
    end

    context 'when block is given' do
      subject { DVD.load { |dvd| dvd.artist = 'some artist' }  }
      before { DVD.should_receive(:detect).and_return('/dev/path') }
      it 'calls proc object' do
        subject
        expect(DVD.instance.artist).to eq('some artist')
      end
    end
  end

  describe '#info' do
    subject { dvd.info }
    let(:dvd) { DVD.instance }

    context 'when DVD.dev is not set' do
      before { DVD.dev = nil }
      it 'raises an RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when DVD.dev is set' do
      before { DVD.dev = '/dev/path' }
      let(:info_data) { 'dvd data' }
      it 'returns DVD disk data' do
        dvd.should_receive(:execute_command).with("dvdbackup --input='/dev/path'", true).and_return(info_data)
        expect(subject).to eq(info_data)
      end
    end
  end
end
