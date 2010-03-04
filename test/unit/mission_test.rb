require 'test_helper'

class MissionTest < ActiveSupport::TestCase
  
  should_belong_to :ngo
  should_have_one :address
  
  should_validate_presence_of :name
  
end
