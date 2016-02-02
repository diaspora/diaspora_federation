class CreateEntity < ActiveRecord::Migration
  def change
    create_table :entities do |t|
      t.belongs_to :author, class_name: "Person", null: false
      t.string     :guid,        null: false
      t.string     :entity_type, null: false

      t.timestamps null: false
    end
  end
end
