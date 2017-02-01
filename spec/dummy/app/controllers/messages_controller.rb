class MessagesController < ApplicationController

  def index
    @inbox = current_user.messages.includes(:user, :author)
    @sent = current_user.sent_messages.includes(:user, :author)
  end

  def new
    @message = Message.new
  end

  def create
    @message = Message.new(message_params.merge(:author => current_user))
    if @message.save
      redirect_to messages_path, :notice => 'Message created successfully!'
    else
      render 'new'
    end
  end

  def show
    @message = current_user.messages.find_by_id(params[:id])
  end

  private

    def message_params
      params.require(:message).permit(:user_id, :content)
    end

end
