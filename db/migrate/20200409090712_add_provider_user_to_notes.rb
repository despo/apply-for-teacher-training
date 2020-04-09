class AddProviderUserToNotes < ActiveRecord::Migration[6.0]
  def change
    add_reference :notes, :provider_user, null: false, foreign_key: true
  end
end
