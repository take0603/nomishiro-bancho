class Users::RegistrationsController < Devise::RegistrationsController
  before_action :ensure_normal_user, only: :destroy

  def ensure_normal_user
    if resource.email == 'guest@example.com'
      redirect_to root_path, alert: 'ゲストユーザーのためアカウントを削除できません。'
    end
  end

  def update
    super
    if account_update_params[:image].present?
      resource.image.attach(account_update_params[:image])    
    end
  end
end
