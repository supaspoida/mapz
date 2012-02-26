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

describe Parse::City do
  subject do
    described_class.new(locality)
  end

  context "when 'New York, NY'" do
    let(:locality) { 'New York, NY' }
    its(:key) { should == 'new-york-ny' }
  end

  context "when 'Jacksonville Beach, FL'" do
    let(:locality) { 'Jacksonville Beach, FL' }
    its(:key) { should == 'jacksonville-beach-fl' }
  end
end

describe Parse::Show do
  let(:raw) do
    'Bisco |  08/21/03 |  Crocodile Rock |  Allentown, PA |  Setlist'
  end

  subject { described_class.new(raw) }

  its(:raw) do
    should == 'Bisco | 08/21/03 | Crocodile Rock | Allentown, PA | Setlist'
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
