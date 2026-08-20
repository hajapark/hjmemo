class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @topic_count = current_user.topics.count
  end
end
