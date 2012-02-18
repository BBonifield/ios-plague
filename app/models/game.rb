class Game
  include Mongoid::Document

  GAME_DURATION = 180

  STATE_PENDING_START = :pending_start
  STATE_RUNNING = :running
  STATE_COMPLETE = :complete

  def self.valid_states
    [ STATE_PENDING_START, STATE_RUNNING, STATE_COMPLETE ]
  end

  field :state, :type => Symbol, :default => STATE_PENDING_START
  field :start_time, :type => DateTime
  field :end_time, :type => DateTime

  validates_inclusion_of :state, :in => self.valid_states

  belongs_to :game_server
  has_many :players

  after_create :assign_waiting_players_to_game

  def assign_waiting_players_to_game
    Session.where(:state => Session::STATE_AWAITING_GAME).each do |session|
      self.players << Player.new( :session_id => session.id )
    end
    self.save
  end

  def start
    if self.state == STATE_PENDING_START
      self.start_time = DateTime.now
      self.end_time = GAME_DURATION.seconds.from_now
      self.state = STATE_RUNNING
      self.save
    else
      false
    end
  end

  def end
    if self.state == STATE_RUNNING
      self.state = STATE_COMPLETE
      self.save
    else
      false
    end
  end

end
