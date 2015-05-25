class AddReferrerToVisitors < ActiveRecord::Migration
  def change
    add_column :visitors, :referrer, :string
  end
end
