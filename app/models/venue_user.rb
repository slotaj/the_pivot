class VenueUser < ActiveRecord::Base
  belongs_to :venue
  belongs_to :user
end
