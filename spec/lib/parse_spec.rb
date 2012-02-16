require 'spec_helper'
require 'parse'

describe Parse do
  describe 'initialization' do
    let(:text) do
      %{Bisco |  08/21/03 |  Crocodile Rock |  Allentown, PA |  Setlist
        Bisco |  08/22/03 |  Bay Center |  Dewey Beach, DE |  Setlist}
    end

    let(:parser) do
      described_class.new(text)
    end

    subject { parser }

    its(:text) { should == text }
    its(:shows) { should have(2).shows }

    describe '#shows' do
      subject { parser.shows }

      its(:first) do
        should == 'Bisco | 08/21/03 | Crocodile Rock | Allentown, PA | Setlist'
      end
      its(:last) do
        should == 'Bisco | 08/22/03 | Bay Center | Dewey Beach, DE | Setlist'
      end
    end
  end
end

describe Parse::Show do
  let(:attributes) do
    { date: '08/21/03',
      venue: 'Crocodile Rock',
      city: 'Allentown',
      state: 'PA' }
  end

  subject { described_class.new(attributes) }

  its(:venue) { should == 'Crocodile Rock' }
  its(:city) { should == 'Allentown' }
  its(:state) { should == 'PA' }
  its(:date) { should == '08/21/03' }
end
