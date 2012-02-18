class GameServer
  include Mongoid::Document

  STATE_AWAITING_CONNECTIONS = :awaiting_connections
  STATE_GAME_STARTING = :game_starting
  STATE_GAME_IN_PROGRESS = :game_in_progress

  def self.valid_states
    [ STATE_AWAITING_CONNECTIONS, STATE_GAME_IN_PROGRESS, STATE_GAME_STARTING ]
  end

  field :state, :type => Symbol, :default => STATE_AWAITING_CONNECTIONS

  validates_inclusion_of :state, :in => self.valid_states

  has_many :games

  def self.singleton
    if self.count == 0
      self.create
    else
      self.first
    end
  end

  def start_game
    if self.state == STATE_AWAITING_CONNECTIONS
      self.state = STATE_GAME_STARTING
      self.games << Game.new
      self.save
    else
      false
    end
  end

  def game_started
    if self.state == STATE_GAME_STARTING
      self.state = STATE_GAME_IN_PROGRESS
      self.save
    else
      false
    end
  end

  def game_finished
    if self.state == STATE_GAME_IN_PROGRESS
      self.state = STATE_AWAITING_CONNECTIONS
      self.save
    else
      false
    end
  end
end
