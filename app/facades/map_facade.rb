class MapFacade
  attr_reader :map

  def initialize(map)
    @map = map
  end

  def allmappers
    @allmappers = map.contributors
  end

  def alltopics
    @alltopics = map.topics.to_a
    @alltopics = @alltopics.delete_if do |t|
      t.permission == "private" && (!authenticated? || (authenticated? && current_user.id != t.user_id))
    end
  end

  def allsynapses
    @allsynapses = map.synapses.to_a
    @allsynapses = @allsynapses.delete_if do |s|
      s.permission == "private" && (!authenticated? || (authenticated? && current_user.id != s.user_id))
    end
  end

  def allmappings
    @allmappings = map.mappings.to_a
    @allmappings = @allmappings.delete_if do |m|
      object = m.mappable #topic or synapse
      object.nil? || (object.permission == "private" && (!authenticated? || (authenticated? && @current.id != object.user_id)))
    end
  end

  def json_contains
    @json = Hash.new
    @json['map'] = @map
    @json['topics'] = @alltopics
    @json['synapses'] = @allsynapses
    @json['mappings'] = @allmappings
    @json['mappers'] = @allmappers
  end
end
