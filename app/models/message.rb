class Message < ApplicationRecord
  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id'
  belongs_to :receiver, class_name: 'User', foreign_key: 'receiver_id'

  scope :between_users, ->(user1_id, user2_id) {
    where('(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)',
          user1_id, user2_id, user2_id, user1_id)
  }
end
