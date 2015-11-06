class Metacode < ActiveRecord::Base
  has_and_belongs_to_many :metacode_sets, join_table: :in_metacode_sets, autosave: true
  has_many :topics

  def hasSelected(user)
    return true if user.settings.metacodes.include? self.id.to_s
    return false
  end
    
  def inMetacodeSet(metacode_set)
    return true if self.metacode_sets.include? metacode_set
    return false
  end
end
