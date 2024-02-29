class AddForeignKeysToMessages < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :messages, :users, column: :receiver_id, on_delete: :cascade
    add_foreign_key :messages, :users, column: :sender_id, on_delete: :cascade
  end
end
