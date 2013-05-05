# coding: utf-8
require 'spec_helper'
require 'musical'

describe Musical::DVD do
  let(:dvd) { Musical::DVD }

  describe '.detect' do
    subject(:detect) { dvd.detect }
    let(:drutil) { 'drutil status' }

    context 'when DVD drive is not found' do
      before do
        Open3.should_receive(:capture2).with(drutil).and_return(['', 0])
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
      before { Open3.should_receive(:capture2).with(drutil).and_return([drutil_out, 0]) }

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
        Open3.should_receive(:capture2).with(drutil).and_return([drutil_out, 0])
        Open3.should_receive(:capture2).with(df).and_return([df_out, 0])
      end

      it { should == '/Volumes/DVD_VIDEO'}
    end
  end
end
