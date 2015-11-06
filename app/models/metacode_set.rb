class MetacodeSet < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :metacodes, join_table: :in_metacode_sets, autosave: true
end
