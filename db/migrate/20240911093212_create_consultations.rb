class CreateConsultations < ActiveRecord::Migration[7.1]
  def change
    create_table :consultations do |t|
      t.references :patient, null: false, foreign_key: true
      t.text :notes_before
      t.text :notes_after
      t.text :notes_to_send
      t.date :date, default: -> { 'CURRENT_DATE' }

      t.timestamps
    end
  end
end
