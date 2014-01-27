class SpentTimeQuery < ActiveRecord::Base
  unloadable
  
  belongs_to :user, :class_name => 'User', :foreign_key => 'user_id'
  
  validates :name, length: { minimum: 1}
end
