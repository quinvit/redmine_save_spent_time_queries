class SpentTimeQuery < ActiveRecord::Base
  unloadable
  
  belongs_to :user, :class_name => 'User', :foreign_key => 'user_id'
  
  validates_length_of :name, :minimum => 1
end
