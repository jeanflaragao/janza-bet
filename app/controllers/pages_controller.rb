class PagesController < ApplicationController
  allow_unauthenticated_access only: [:about, :authentication]
  before_action :resume_session, only: [:authentication]

  def about
  end

  def authentication
  end

  def account
  end
end
