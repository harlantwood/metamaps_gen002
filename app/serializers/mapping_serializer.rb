class MappingSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id,
             :xloc,
             :yloc,
             :created_at,
             :updated_at
  has_one :user
  has_one :map
  has_one :mappable, polymorphic: true

  def filter(keys)
    keys.delete(:xloc) unless object.mappable_type == "Topic"
    keys.delete(:yloc) unless object.mappable_type == "Topic"
    keys
  end
end
