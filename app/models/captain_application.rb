class CaptainApplication < ActiveRecord::Base
  extend DynamicBaseDrop::Droppable
  
  is_droppable

  attr_accessible :has_first_aid_cert, :offers, :reason_why
  
  belongs_to :user
  
  validates_presence_of :user, :offers, :reason_why
  validates_inclusion_of :accepted, :has_first_aid_cert, :in => [true, false, nil]
  
end

# == Schema Info
#
# Table name: captain_applications
#
#  id                 :integer(4)      not null, primary key
#  user_id            :integer(4)
#  accepted           :boolean(1)
#  has_first_aid_cert :boolean(1)
#  offers             :text
#  reason_why         :text
#  created_at         :datetime
#  updated_at         :datetime