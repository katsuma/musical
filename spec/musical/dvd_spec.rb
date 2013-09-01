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
      before do
        DVD.should_receive(:execute_command).with(drutil).and_return(drutil_out)
      end

      it { should == '/dev/disk3' }
    end
  end

  describe '.device_path' do
    subject { DVD.device_path }
    context 'device_path class property is not set' do
      it 'returns nil' do
        expect(subject).to eq(nil)
      end
    end

    context 'device_path class property is set' do
      before{ DVD.device_path = '/dev/path' }
      it 'returns property value' do
        expect(subject).to eq('/dev/path')
      end
    end
  end

  describe '.load' do
    before { DVD.device_path = nil }
    before { DVD.any_instance.should_receive(:info).and_return('info data') }

    context 'when options are not given' do
      subject { DVD.load }

      context 'and if device_path is set' do
        before { DVD.device_path = '/dev/some/path' }
        it 'does not call DVD.detect' do
          DVD.should_not_receive(:detect)
          subject
        end
      end

      context 'and if dev path is not set' do
        it 'sets dev path by DVD.detect' do
          DVD.should_receive(:detect).and_return('/dev/some/path')
          subject
          expect(DVD.device_path).to eq('/dev/some/path')
        end
      end
    end

    context 'when options are given' do
      subject { DVD.load(options) }
      context 'and if option does not have `forcibly` key' do
        let(:options) { { device_path: '/dev/path', title: 'some title' } }

        it 'sets dev path by given option' do
          subject
          expect(DVD.device_path).to eq('/dev/path')
        end

        it 'sets title by given option' do
          subject
          expect(DVD.instance.title).to eq('some title')
        end
      end

      context 'and if option has `forcibly` key' do
        let(:options) { { forcibly: true } }
        before { DVD.device_path = '/dev/some/path' }

        it 'calls DVD.detect forcibly even if device path is already set' do
          DVD.should_receive(:detect).and_return('/dev/some/path')
          subject
        end
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
      before { DVD.device_path = nil }
      it 'raises an RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when DVD.dev is set' do
      before { DVD.device_path = '/dev/path' }
      let(:info_data) { 'dvd data' }
      it 'returns DVD disk data' do
        dvd.should_receive(:execute_command).with("dvdbackup --info --input='/dev/path'", true).and_return(info_data)
        expect(subject).to eq(info_data)
      end
    end
  end

  describe '#title_sets' do
    subject { dvd.title_sets }
    let(:info) do
      <<"EOM"
Title Sets:

        Title set 1
                The aspect ratio of title set 1 is 16:9
                Title set 1 has 1 angle
                Title set 1 has 1 audio track
                Title set 1 has 0 subpicture channels

                Title included in title set 1 is
                        Title 1:
                                Title 1 has 15 chapters
                                Title 1 has 2 audio channels
EOM
    end
    let(:dvd) { DVD.instance }

    before { dvd.should_receive(:info).and_return(info) }

    it 'returns each pair of title and chapter data' do
      expect(subject).to be_an Array
      expect(subject.size).to eq(1)
      expect(subject.first[:title]).to eq(1)
      expect(subject.first[:chapter]).to eq(15)
    end
  end
end
