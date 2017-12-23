class AddItemsCountToWorks < ActiveRecord::Migration[4.2]
  def change
    add_column :works, :items_count, :integer, null: false, default: 0
    add_index :works, :items_count
  end
end
