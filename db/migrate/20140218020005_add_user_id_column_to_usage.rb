class AddUserIdColumnToUsage < ActiveRecord::Migration
  def change
    add_column :usage, :user_id, :integer
  end
end
