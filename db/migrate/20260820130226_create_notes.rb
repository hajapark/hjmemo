class CreateNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :notes do |t|
      t.references :topic, null: false, foreign_key: true
      t.text :question, null: false
      t.text :answer, null: false

      t.timestamps
    end
  end
end
