class Business < ActiveRecord::Base
  has_many: :categories
  has_one: :location
end
