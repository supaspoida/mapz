require 'slim_spec_helper'
require 'parse'

describe Parse do
  let(:text) do
    <<-json
      [
        { "title": "08/21/03 - Croc Rock - Patio - Allentown, PA", "phantasyTourId": "1"},
        { "title": "08/22/03 - Bay Center - Dewey Beach, DE", "phantasyTourId": "2" }
      ]
    json
  end

  let(:parser) { described_class.new(text) }

  subject { parser }

  describe 'initialization' do
    its(:raw_json) { should == text }
    it { should have(2).shows }
  end

  describe '#shows' do
    let(:shows) { parser.shows }

    context 'first show' do
      subject { shows.first }

      its(:title) { should == "08/21/03 - Croc Rock - Patio, Allentown, PA" }
      its(:city)  { should == "Allentown" }
      its(:date)  { should == "08/21/03" }
      its(:venue) { should == "Croc Rock - Patio" }
      its(:state) { should == "PA" }
      its(:phantasy_tour_id) { should == "1" }
    end

    context 'second show' do
      subject { shows.last }

      its(:title) { should == "08/22/03 - Bay Center, Dewey Beach, DE" }
      its(:city)  { should == "Dewey Beach" }
      its(:date)  { should == "08/22/03" }
      its(:venue) { should == "Bay Center" }
      its(:state) { should == "DE" }
      its(:phantasy_tour_id) { should == "2" }
    end
  end
end

class City
  NotFound = Class.new(RuntimeError)
end

describe Parse::City do
  describe '.locate' do
    let(:locate) do
      described_class.locate('New York, NY')
    end

    subject { locate }

    context 'when cached city exists' do
      let(:cached_city) { stub }

      before do
        City.stub(:locate).with('New York, NY') { cached_city }
      end

      it { should == cached_city }
    end

    context 'when city is not cached' do
      let(:geocode) { stub(center: []) }

      before do
        Parse::Geocoder.stub(:locate) { geocode }
        City.stub(:locate).with('New York, NY').and_raise(City::NotFound)
        City.stub(:save_geocode)
      end

      it { should == geocode }

      it 'stores the city' do
        City.should_receive(:save_geocode).with(geocode)
        locate
      end
    end
  end
end

describe Parse::Title do
  let(:raw) do
    '08/21/03 - Crocodile Rock - Allentown, PA'
  end

  subject { described_class.new(raw) }

  its(:raw) do
    should == '08/21/03 - Crocodile Rock - Allentown, PA'
  end
  its(:venue) { should == 'Crocodile Rock' }
  its(:city) { should == 'Allentown' }
  its(:state) { should == 'PA' }
  its(:date) { should == '08/21/03' }
  its(:attributes) do
    should == { venue: 'Crocodile Rock',
                city: 'Allentown',
                state: 'PA',
                date: '08/21/03' }
  end
end
