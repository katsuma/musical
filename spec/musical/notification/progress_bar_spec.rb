# coding: utf-8
require 'spec_helper'
require 'musical'

describe Musical::Notification::ProgressBar do
  describe '.create' do
    subject!(:progress_bar) { described_class.create(total: 3, format: '') }

    it 'returns unfinished ProgressBar' do
      expect(progress_bar.finished?).to be_false
    end
  end
end
