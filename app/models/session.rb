class Session
  include Mongoid::Document

  attr_accessible :name, :mac_address

  STATE_AWAITING_GAME = :awaiting_game
  STATE_IN_GAME = :in_game
  STATE_OFFLINE = :offline

  def self.valid_states
    [ STATE_AWAITING_GAME, STATE_IN_GAME, STATE_OFFLINE ]
  end

  field :name, :type => String
  field :state, :type => Symbol, :default => STATE_AWAITING_GAME
  field :start_time, :type => DateTime, :default => lambda { DateTime.now }
  field :end_time, :type => DateTime
  field :mac_address, :type => String

  validates_presence_of :name, :mac_address
  validates_inclusion_of :state, :in => self.valid_states

  has_many :players

  before_create :kill_stale_sessions

  def kill_stale_sessions
    Session.where(:mac_address => self.mac_address).and(:state.ne => STATE_OFFLINE).each do |stale_session|
      stale_session.kill
    end
  end

  def active_player
    gs = GameServer.singleton
    if gs.active_game
      players.select { |p| gs.active_game.players.map{|p| p.id}.include?(p.id) }.first
    end
  end

  # state management

  def started_game
    if self.state == STATE_AWAITING_GAME
      self.state = STATE_IN_GAME
      self.save
    else
      false
    end
  end

  def game_ended
    if self.state == STATE_IN_GAME
      self.state = STATE_AWAITING_GAME
      self.save
    else
      false
    end
  end

  def kill
    self.state = STATE_OFFLINE
    self.end_time = DateTime.now
    self.save
  end

end
