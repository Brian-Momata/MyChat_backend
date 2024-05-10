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
  
    # Subquery to get the latest messages for each sender-receiver pair
    latest_messages_subquery = Message.select('GREATEST(MAX(created_at), MAX(updated_at)) AS latest_time')
                                      .where('(sender_id = ? OR receiver_id = ?)', @current_user.id, @current_user.id)
                                      .group('CASE WHEN sender_id = ? THEN receiver_id ELSE sender_id END', @current_user.id)
  
    # Join with the messages table to get the full message objects
    @latest_messages = Message.joins("INNER JOIN (#{latest_messages_subquery.to_sql}) AS latest ON GREATEST(messages.created_at, messages.updated_at) = latest.latest_time")
                              .where('(sender_id = ? OR receiver_id = ?)', @current_user.id, @current_user.id)
                              .order('latest.latest_time DESC')
  
    render json: @latest_messages
  end
end
