class RemoveLongitudeFromBusiness < ActiveRecord::Migration
  def change
    remove_column :businesses, :longitude, :float
  end
end
