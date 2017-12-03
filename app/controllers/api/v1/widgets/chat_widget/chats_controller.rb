class Api::V1::Widgets::ChatWidget::ChatsController < ApplicationController
  before_action :find_chat
  before_action :find_app
  before_action :access_control

  def show
    @members = @app.members
    @online_users = @chat.users
    @online_users_count = @members.reject {|user| !user.is_online_now? }.count
  end

  private

  def find_chat
    app = App.find_by(permalink: params[:id])
    @chat = app.present? ? app.widgets.where(widgetable_type: 'Widgets::ChatWidget::Chat').first.try(:widgetable) : ::Widgets::ChatWidget::Chat.find(params[:id])
    if @chat.nil?
      render 'api/v1/shared/failure', locals: { errors: [{ message: 'record not found' }] }, status: :not_found
    end
  end

  def find_app
    @app = @chat.widget.app
  end

  def access_control
    if @app.privy? and !current_user.is_member_of?(@app)
      render 'api/v1/shared/failure', locals: { errors: [{ message: 'access denied' }] }, status: :unauthorized
      return
    end
  end
end