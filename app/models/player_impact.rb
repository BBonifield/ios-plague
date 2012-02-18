class PlayerImpact
  include Mongoid::Document

  field :magnitude, :type => BigDecimal
  field :incident_time, :type => DateTime, :default => lambda { DateTime.now }

  belongs_to :player
end
