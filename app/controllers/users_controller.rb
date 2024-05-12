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
      ActionCable.server.broadcast("chat_#{params[:receiver_id]}", "")
      ActionCable.server.broadcast("chat_#{params[:receiver_id]}#{params[:sender_id]}", @message)
      render json: @message, status: :created
    else
      # Handle validation errors or other failures
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  def update_avatar
    @user = User.find(params[:user_id])
    @user.avatar = params[:avatar]
  
    if @user.save
      render json: { message: 'Avatar updated successfully', user: @user }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def sent_messages
    @current_user = User.find(params[:user_id])

    # Retrieve the latest message for each receiver_id
    latest_messages = Message.select('MAX(created_at) AS latest_created_at, receiver_id')
                             .where(sender_id: @current_user.id)
                             .group(:receiver_id)

    # Join with the messages table to get the full message objects
    @sent_messages = Message.joins("INNER JOIN (#{latest_messages.to_sql}) AS latest ON messages.receiver_id = latest.receiver_id AND messages.created_at = latest.latest_created_at")
                            .where(sender_id: @current_user.id)
                            .order('messages.created_at DESC')

    render json: @sent_messages
  end

  def latest_between_users
    sender_id = params[:sender_id]
    receiver_id = params[:receiver_id]
    
    latest_message = Message.between_users(sender_id, receiver_id)
                           .order('created_at DESC')
                           .first
    
    render json: latest_message
  end  
end
