require 'rails_helper'

RSpec.describe UCASMatching::FileDownloadCheck do
  describe '#check' do
    it 'succeeds if a download has taken before the weekend' do
      Timecop.freeze(2020, 12, 7, 0, 0) do # Monday
        UCASMatching::FileDownloadCheck.set_last_sync(3.days.ago) # Friday

        expect(UCASMatching::FileDownloadCheck.new.check).to eql('There was a succesful UCAS file download that has taken place since the last weekday')
      end
    end

    it 'succeeds if a download has taken place on the previous weekday' do
      Timecop.freeze(2020, 12, 4, 0, 0) do # Friday
        UCASMatching::FileDownloadCheck.set_last_sync(1.day.ago) # Thursday

        expect(UCASMatching::FileDownloadCheck.new.check).to eql('There was a succesful UCAS file download that has taken place since the last weekday')
      end
    end

    it 'fails if the file has never been downloaded' do
      UCASMatching::FileDownloadCheck.clear_last_sync

      expect(UCASMatching::FileDownloadCheck.new.check).to eql('Cannot find the time when the last UCAS file download took place')
    end

    it 'fails if the download has not happened since the last weekday' do
      UCASMatching::FileDownloadCheck.set_last_sync(Time.zone.now.prev_weekday - 1.day)

      expect(UCASMatching::FileDownloadCheck.new.check).to eql('There was no UCAS file download taking place yesterday')
    end
  end
end
