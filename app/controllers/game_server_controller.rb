class GameServerController < ApplicationController
  def index

  end

  def active_sessions
    render :json => Session.where(:state => Session::STATE_AWAITING_GAME)
  end

  def start_game
    gs = GameServer.singleton
    gs.start_game
  end

  def game_started
    gs = GameServer.singleton
    gs.games.last.start
  end
end
