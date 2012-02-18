class Player
  include Mongoid::Document

  STATE_INFECTED = :infected
  STATE_NOT_INFECTED = :not_infected

  def self.valid_states
    [ STATE_INFECTED, STATE_NOT_INFECTED ]
  end

  field :state, :type => Symbol, :default => STATE_NOT_INFECTED
  field :points, :type => Integer, :default => 0

  validates_inclusion_of :state, :in => self.valid_states

  belongs_to :game
  belongs_to :session
  has_many :player_impacts

  def infect
    if self.state == STATE_NOT_INFECTED
      self.state = STATE_INFECTED
      self.save
    else
      false
    end
  end

  def cure
    if self.state == STATE_INFECTED
      self.state == STATE_NOT_INFECTED
      self.save
    else
      false
    end
  end

end
