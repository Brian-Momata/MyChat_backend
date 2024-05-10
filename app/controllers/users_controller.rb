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
  
    # Query for the latest messages where the current user is the sender
    sent_messages_query = Message.where(sender_id: @current_user.id)
                                 .select('MAX(created_at) AS latest_time, receiver_id AS user_id, content')
                                 .group(:receiver_id)
  
    # Query for the latest messages where the current user is the receiver
    received_messages_query = Message.where(receiver_id: @current_user.id)
                                     .select('MAX(created_at) AS latest_time, sender_id AS user_id, content')
                                     .group(:sender_id)
  
    # Union of sent and received messages
    @latest_messages = Message.from(sent_messages_query.union(received_messages_query).to_sql)
                              .order('latest_time DESC')
  
    render json: @latest_messages
  end  
end
