Category.delete_all
categories = [
  {:name =>'active', :display_name => 'Active Life'},
  {:name =>'arts', :display_name => 'Arts'}
  {:name =>'auto', :display_name => 'Auto'}
  :name =>'beautysvc', :display_name => 'Beauty Services'
  :name =>'education', :display_name =>
  :name =>'eventservices', :display_name =>
  :name =>'financialservices', :display_name =>
  :name =>'food',
  :name =>'health',
  :name =>'homeservices',
  :name =>'hotelstravel',
  :name =>'localflavor',
  :name =>'localservices',
  :name =>'massmedia',
  :name =>'nightlife',
  :name =>'pets',
  :name =>'professional',
  :name =>'publicservicesgovt',
  :name =>'realestate',
  :name =>'religiousorgs',
  :name =>'restaurants',
  :name =>'shopping'
]
Category.create(categories)

businesses = JSON.parse(IO.read("#{Rails.root}/db/Business.all.json"))
businesses.each do |business|
  Business.create(business)
end

categories = JSON.parse(IO.read("#{Rails.root}/db/Category.all.json"))
categories.each do |cat|
  Category.create(cat)
end

locations = JSON.parse(IO.read("#{Rails.root}/db/Location.all.json"))
locations.each do |loc|
  Location.create(loc)
end



