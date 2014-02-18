class CreateUsages < ActiveRecord::Migration
  def change
    create_table :usage do |t|
      t.integer :timestamp, :null => false
      t.integer :value, :null => false

      t.timestamps
    end
  end
end
