class UsersController < ApplicationController
  def index
    @users = User.all
    render json: @users
  end

  def send_message
    receiver = User.find(params[:receiver_id])
    sender = User.find(params[:sender_id])
    @message = sender.sent_messages.build(receiver: receiver, content: params[:content])

    if @message.save
      # Message created successfully
      render json: @message, status: :created
    else
      # Handle validation errors or other failures
      render json: @message.errors, status: :unprocessable_entity
    end
  end
end
