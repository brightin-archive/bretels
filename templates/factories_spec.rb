require 'rails_helper'

RSpec.describe 'validate FactoryGirl factories' do
  FactoryGirl.factories.each do |factory|
    it "#{factory.name} should be valid" do
      expect(build(factory.name)).to be_valid
    end
  end
end
