require 'slim_spec_helper'
require 'parse'

describe Parse do
  describe 'initialization' do
    let(:text) do
      %{Bisco |  08/21/03 |  Crocodile Rock |  Allentown, PA |  Setlist
        Bisco |  08/22/03 |  Bay Center |  Dewey Beach, DE |  Setlist}
    end

    subject { described_class.new(text) }

    its(:text) { should == text }
    its(:shows) { should have(2).shows }
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
