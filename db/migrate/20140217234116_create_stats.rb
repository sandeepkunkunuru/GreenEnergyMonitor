class CreateStats < ActiveRecord::Migration
  def change
    create_table :stats do |t|
      t.integer :timestamp , :null => false
      t.integer :average
      t.integer :maximum
      t.integer :minimum

      t.timestamps
    end
  end
end
