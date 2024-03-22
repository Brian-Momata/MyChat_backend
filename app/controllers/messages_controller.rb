class MessagesController < ApplicationController
  def fetch_messages
    current_user_id = params[:current_user_id]
    clicked_user_id = params[:clicked_user_id]

    @messages = Message.between_users(current_user_id, clicked_user_id)
    render json: @messages
  end
end
