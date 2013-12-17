class Spree::UserRegistrationsController < Devise::RegistrationsController
  helper 'spree/users', 'spree/base', 'spree/store'

  if defined?(Spree::Dash)
    helper 'spree/analytics'
  end

  include Spree::Core::ControllerHelpers::Auth
  include Spree::Core::ControllerHelpers::Common
  include Spree::Core::ControllerHelpers::Order
  include Spree::Core::ControllerHelpers::SSL

  ssl_required
  before_filter :check_permissions, :only => [:edit, :update]
  skip_before_filter :require_no_authentication

  # GET /resource/sign_up
  def new
    super
    @user = resource
  end

  # POST /resource/sign_up
  def create
    @user = build_resource(params[:spree_user])
    if resource.save
      sign_in(:spree_user, @user)
      session[:spree_user_signup] = true
      associate_user
      respond_to do |format|
        format.html {
          set_flash_message(:notice, :signed_up)
          sign_in_and_redirect(:spree_user, @user)
        }
        format.js {
          render :json => {:success => true}.to_json
        }
      end
    else
      respond_to do |format|
        puts resource
        format.html {
          clean_up_passwords(resource)
          render :new
        }
        format.js {
          render :json => {:success => false}.to_json
        }
      end
    end
  end

  # GET /resource/edit
  def edit
    super
  end

  # PUT /resource
  def update
    super
  end

  # DELETE /resource
  def destroy
    super
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  def cancel
    super
  end

  protected
    def check_permissions
      authorize!(:create, resource)
    end

end
