class FavoritesController < ApplicationController
  before_action :require_user_logged_in
  
  def create
    # viewからお気に入りしたい投稿のmicropost_idを送ってもらう
    micropost = Micropost.find(params[:micropost_id])
    current_user.favorite(micropost)
    flash[:success] = 'お気に入り登録しました'
    redirect_back(fallback_location: root_path)
  end

  def destroy
    micropost = Micropost.find(params[:micropost_id])
    current_user.unfavorite(micropost)
    flash[:success] = 'お気に入りから解除しました'
    redirect_back(fallback_location: root_path)
  end
end
