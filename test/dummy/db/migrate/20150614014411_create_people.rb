class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string "guid",                  null: false
      t.text   "url",                   null: false
      t.string "diaspora_handle",       null: false
      t.text   "serialized_public_key", null: false

      t.timestamps null: false
    end
  end
end
