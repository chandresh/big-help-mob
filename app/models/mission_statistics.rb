class MissionStatistics
  
  UserLocation = Struct.new(:postcode, :lat, :lng, :count)
  
  ROLE_CHOICES  = [["Anyone", ""], ["Captains", "captains"], ["Sidekicks", "sidekicks"]]
  STATE_CHOICES = [["All", ""], ["Approved", "approved"], ["Pending", "pending"]]
  
  attr_accessor :mission
  
  def initialize(mission)
    @mission = mission
  end
  
  def participations
    @participations ||= @mission.mission_participations.all(:include => {:role => nil, :user => nil, :pickup => {:pickup => :address}})
  end
  
  def to_user_locations(state = nil, type = nil)
    locations = []
    grouped = participations_for(state, type).group_by { |p| p.user.postcode.to_i }
    grouped.each_pair do |postcode, participations|
      u = participations.first.user
      locations << UserLocation.new("%04d" % postcode, u.postcode_lat, u.postcode_lng, participations.size)
    end
    locations
  end
  
  def participations_for(state, type)
    state, type = state.to_s.strip.downcase, type.to_s.strip.downcase
    Rails.logger.debug "Filtering on: #{state}, #{type}"
    all_participations = case state
    when "pending"
      pending_participations
    when "approved"
      approved_participations
    else
      participations
    end
    case type
    when "sidekicks"
      all_participations = sidekicks(all_participations)
    when "captains"
      all_participations = captains(all_participations)
    end
    all_participations
  end
  
  def pending_participations
    participations.select { |p| p.still_preparing? }
  end
  
  def approved_participations
    participations.select { |p| p.approved? }
  end
  
  def other_participations
    participations - preparing_participations - approved_participations
  end
  
  def sidekicks(collection = participations)
    collection.select { |c| c.sidekick? }
  end
  
  def captains(collection = participations)
    collection.select { |c| c.captain? }
  end
  
  def approved_sidekicks
    sidekicks approved_participations
  end
  
  def approved_captains
    captains approved_participations
  end
  
  def count(collection = :all, type = :all)
    ps = (collection == :all ? participations : send(:"#{collection}_participations"))
    ps = send(type, ps) unless type == :all
    ps.size
  end
  
  def pickups
    pickups = ActiveSupport::OrderedHash.new
    grouped_sidekicks = approved_sidekicks.group_by { |p| p.pickup_id }
    unordered = @mission.mission_pickups.all(:include => {:pickup => :address})
    unordered.sort_by { |mp| mp.pickup_at }.each do |pickup|
      pickups[pickup] = grouped_sidekicks[pickup.id] || []
    end
    pickups
  end
  
end