class CreateTopics < ActiveRecord::Migration[8.1]
  def change
    create_table :topics do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false, limit: 100

      t.timestamps
    end

    add_index :topics, [ :user_id, :name ], unique: true
  end
end
