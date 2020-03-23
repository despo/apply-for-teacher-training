class CreateValidationErrors < ActiveRecord::Migration[6.0]
  def change
    create_table :validation_errors do |t|
      t.string :form_object
      t.json :what_went_wrong

      t.timestamps
    end
  end
end
