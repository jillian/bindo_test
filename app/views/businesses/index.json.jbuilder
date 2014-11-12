json.array!(@businesses) do |business|
  json.extract! business, :id, :name, :image, :category, :latitude, :longitude, :zipcode, :address, :city, :data_key_id, :integer
  json.url business_url(business, format: :json)
end
