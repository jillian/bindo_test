class CreateBusinesses < ActiveRecord::Migration
  def change
    create_table :businesses do |t|
      t.string  :name
      t.string  :address
      t.string  :city
      t.string  :state
      t.integer :zipcode
      t.string  :image

      t.timestamps
    end
  end
end
