require 'spec_helper'
require 'parse'

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
