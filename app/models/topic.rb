class Topic < ActiveRecord::Base
  include TopicsHelper

  belongs_to :user

  has_many :synapses1, :class_name => 'Synapse', :foreign_key => 'node1_id', dependent: :destroy
  has_many :synapses2, :class_name => 'Synapse', :foreign_key => 'node2_id', dependent: :destroy
  has_many :topics1, :through => :synapses2, :source => :topic1
  has_many :topics2, :through => :synapses1, :source => :topic2

  has_many :mappings, as: :mappable, dependent: :destroy
  has_many :maps, :through => :mappings

  validates :permission, presence: true
  validates :permission, inclusion: { in: Perm::ISSIONS.map(&:to_s) }
    
  # This method associates the attribute ":image" with a file attachment
  has_attached_file :image
    
  #, styles: {
  # thumb: '100x100>',
  # square: '200x200#',
  # medium: '300x300>'
  #}

  # Validate the attached image is image/jpg, image/png, etc
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
  
  # This method associates the attribute ":image" with a file attachment
  has_attached_file :audio
  # Validate the attached audio is audio/wav, audio/mp3, etc
  validates_attachment_content_type :audio, :content_type => /\Aaudio\/.*\Z/   
    
  def synapses
     synapses1 + synapses2
  end
  
  def relatives
     topics1 + topics2
  end

  belongs_to :metacode

  scope :relatives, ->(topic_id = nil) { 
    includes(:synapses1)
    .includes(:synapses2)
    .where('synapses.node1_id = ? OR synapses.node2_id = ?', topic_id, topic_id)
    .references(:synapses)
  }

  def user_name
    user.name
  end

  def user_image
    user.image.url
  end

  def map_count
    maps.count
  end

  def synapse_count
    synapses.count
  end

  def inmaps
    maps.map(&:name)
  end

  def inmapsLinks
    maps.map(&:id)
  end

  def as_json(options={})
    super(:methods =>[:user_name, :user_image, :map_count, :synapse_count, :inmaps, :inmapsLinks])
  end

  def topic_autocomplete_method
    "Get: #{self.name}"
  end
  
  def mk_permission
    Perm.short(permission)
  end

  # has no viewable synapses helper function
  def has_viewable_synapses(current)
  	result = false
  	synapses.each do |synapse|
  		if synapse.authorize_to_show(current)
  			result = true
  		end
  	end
  	result
  end
end
