categories = ['active','arts','auto','beautysvc','education','eventservices','financialservices','food','health','homeservices','hotelstravel','localflavor','localservices','massmedia','nightlife','pets','professional','publicservicesgovt','realestate','religiousorgs','restaurants','shopping']
Category.create(categories)

#categories should have a hash name:category_name
#create object called business categories and saved id of business and name of category
#separate model but not hard coded to any specific list and a biz can have many categories
#in category model wouldn't need this garbage, just create category object every time you created a biz that had a category

# new_category = business.categories.new
# new_category.name = category
# new_category.save