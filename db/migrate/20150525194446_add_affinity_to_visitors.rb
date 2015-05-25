class AddAffinityToVisitors < ActiveRecord::Migration
  def change
    add_column :visitors, :affinity, :string
  end
end
