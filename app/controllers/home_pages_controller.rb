class HomePagesController < ApplicationController
  def index
    @user = User.last
  end

  def home
  end
end
