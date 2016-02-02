class AddSerializedPrivateKeyToPerson < ActiveRecord::Migration
  def change
    add_column :people, :serialized_private_key, :text
  end
end
