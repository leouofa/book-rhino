class CreateOperations < ActiveRecord::Migration[8.0]
  def change
    create_table :operations do |t|
      t.references :user, foreign_key: true
      t.references :resource, polymorphic: true
      t.string :operation_type, null: false
      t.string :job_class, null: false
      t.string :provider_job_id
      t.string :status, null: false, default: 'queued'
      t.jsonb :metadata, null: false, default: {}
      t.string :error_class
      t.text :error_message
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :operations, :status
    add_index :operations, :created_at
  end
end
