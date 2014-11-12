class CreateBusinesses < ActiveRecord::Migration
  def change
    create_table :businesses do |t|
      t.string :name
      t.string :image
      t.string :category
      t.float :latitude
      t.float :longitude
      t.integer :zipcode
      t.string :address
      t.string :city
      t.string :data_key_id
      t.string :integer

      t.timestamps
    end
  end
end
