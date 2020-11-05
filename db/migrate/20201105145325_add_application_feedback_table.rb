class AddApplicationFeedbackTable < ActiveRecord::Migration[6.0]
  def change
    create_table :application_feedback do |t|
      t.string :section
      t.string :path
      t.string :page_title
      t.boolean :issues
      t.boolean :understands_section
      t.boolean :need_more_information
      t.boolean :answer_does_not_fit_format
      t.string :other_feedback
      t.boolean :consent_to_be_contacted
      t.timestamps
    end
  end
end
