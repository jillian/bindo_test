class Business < ActiveRecord::Base
  has_one :category
  has_one :location

  scope :by_category, ->(category_name) do
  joins(:category)
    .where("categories.name = ':name'", name: category_name)
  end
end
