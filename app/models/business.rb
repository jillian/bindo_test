class Business < ActiveRecord::Base
  has_one :category
  has_one :location
end
