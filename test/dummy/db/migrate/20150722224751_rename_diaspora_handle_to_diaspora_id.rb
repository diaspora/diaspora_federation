class RenameDiasporaHandleToDiasporaId < ActiveRecord::Migration
  def change
    rename_column :people, :diaspora_handle, :diaspora_id
  end
end
