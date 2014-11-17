class RemoveDataKeyIdFromBusiness < ActiveRecord::Migration
  def change
    remove_column :businesses, :data_key_id, :integer
  end
end
