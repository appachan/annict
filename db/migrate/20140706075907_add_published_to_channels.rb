class AddPublishedToChannels < ActiveRecord::Migration[4.2]
  def change
    add_column :channels, :published, :boolean, null: false, default: true, after: :name
    add_index  :channels, :published
  end
end
