class CreateAccessLogs < ActiveRecord::Migration[8.1]
  def change
    # Append-only log of who saw or changed which patient. patient_id and consultation_id
    # have no foreign key on purpose: the log must outlive the records it refers to.
    create_table :access_logs do |t|
      t.references :user, foreign_key: true, index: false
      t.bigint :patient_id
      t.bigint :consultation_id
      t.string :action, null: false
      t.string :ip_address
      t.datetime :created_at, null: false
    end

    add_index :access_logs, %i[patient_id created_at]
    add_index :access_logs, %i[user_id created_at]
    add_index :access_logs, :created_at
  end
end
