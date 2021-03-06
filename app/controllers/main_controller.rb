class MainController < ApplicationController
  include TopicsHelper
  include MapsHelper
  include UsersHelper
  include SynapsesHelper

  after_action :verify_policy_scoped
   
  respond_to :html, :json
  
  # home page
  def home
    @maps = policy_scope(Map).order("updated_at DESC").page(1).per(20)
    respond_to do |format|
        format.html { 
          if not authenticated?
            render 'main/home'
          else 
            render 'maps/activemaps'
          end
        }
    end
  end
  
  ### SEARCHING ###
  
  # get /search/topics?term=SOMETERM
  def searchtopics
    term = params[:term]
    user = params[:user] ? params[:user] : false
    
    if term && !term.empty? && term.downcase[0..3] != "map:" && term.downcase[0..6] != "mapper:" && term.downcase != "topic:"
      
      #remove "topic:" if appended at beginning
      term = term[6..-1] if term.downcase[0..5] == "topic:"
      
      #if desc: search desc instead
      desc = false
      if term.downcase[0..4] == "desc:"
        term = term[5..-1] 
        desc = true
      end
      
      #if link: search link instead
      link = false
      if term.downcase[0..4] == "link:"
        term = term[5..-1] 
        link = true
      end
      
      #check whether there's a filter by metacode as part of the query
      filterByMetacode = false
      Metacode.all.each do |m|
        lOne = m.name.length+1
        lTwo = m.name.length
        
        if term.downcase[0..lTwo] == m.name.downcase + ":"
          term = term[lOne..-1] 
          filterByMetacode = m
        end
      end

      search = '%' + term.downcase + '%'
      builder = policy_scope(Topic)
      
      if filterByMetacode
        if term == ""
          builder = builder.none
        else
          builder = builder.where('LOWER("name") like ? OR
                                   LOWER("desc") like ? OR
                                   LOWER("link") like ?', search, search, search)
          builder = builder.where(metacode_id: filterByMetacode.id)
        end
      elsif desc
        builder = builder.where('LOWER("desc") like ?', search)
      elsif link
        builder = builder.where('LOWER("link") like ?', search)
      else #regular case, just search the name
        builder = builder.where('LOWER("name") like ? OR
                                 LOWER("desc") like ? OR
                                 LOWER("link") like ?', search, search, search)
      end

      builder = builder.where(user: user) if user
      @topics = builder.order(:name)
    else
      @topics = []
    end

    render json: autocomplete_array_json(@topics)
  end
  
  # get /search/maps?term=SOMETERM
  def searchmaps
    term = params[:term]
    user = params[:user] ? params[:user] : nil
    
    if term && !term.empty? && term.downcase[0..5] != "topic:" && term.downcase[0..6] != "mapper:" && term.downcase != "map:"
    
      #remove "map:" if appended at beginning
      term = term[4..-1] if term.downcase[0..3] == "map:"
      
      #if desc: search desc instead
      desc = false
      if term.downcase[0..4] == "desc:"
        term = term[5..-1] 
        desc = true
      end

      search = '%' + term.downcase + '%'
      builder = policy_scope(Map)

      if desc
        builder = builder.where('LOWER("desc") like ?', search)
      else
        builder = builder.where('LOWER("name") like ?', search)
      end
      builder = builder.where(user: user) if user
      @maps = builder.order(:name)
    else
      @maps = []
    end
    
    render json: autocomplete_map_array_json(@maps)
  end
  
  # get /search/mappers?term=SOMETERM
  def searchmappers
    term = params[:term]
    if term && !term.empty?  && term.downcase[0..3] != "map:" && term.downcase[0..5] != "topic:" && term.downcase != "mapper:"
    
      #remove "mapper:" if appended at beginning
      term = term[7..-1] if term.downcase[0..6] == "mapper:"
      search = term.downcase + '%'
      builder = policy_scope(User) # TODO do I need to policy scope? I guess yes to verify_policy_scoped
      builder = builder.where('LOWER("name") like ?', search)
      @mappers = builder.order(:name)
    else
      @mappers = []
    end
    render json: autocomplete_user_array_json(@mappers)
  end 
  
  # get /search/synapses?term=SOMETERM OR
  # get /search/synapses?topic1id=SOMEID&topic2id=SOMEID
  def searchsynapses
    term = params[:term]
    topic1id = params[:topic1id]
    topic2id = params[:topic2id]

    if term && !term.empty?
      @synapses = policy_scope(Synapse).where('LOWER("desc") like ?', '%' + term.downcase + '%').order('"desc"')

      # remove any duplicate synapse types that just differ by 
      # leading or trailing whitespaces
      collectedDesc = []
      @synapses.to_a.uniq(&:desc).delete_if {|s|
        desc = s.desc == nil || s.desc == "" ? "" : s.desc.strip
        if collectedDesc.index(desc) == nil
          collectedDesc.push(desc)
          boolean = false
        else
          boolean = true
        end
      }
    elsif topic1id && !topic1id.empty?
      @one = policy_scope(Synapse).where('node1_id = ? AND node2_id = ?', topic1id, topic2id)
      @two = policy_scope(Synapse).where('node2_id = ? AND node1_id = ?', topic1id, topic2id)
      @synapses = @one + @two
      @synapses.sort! {|s1,s2| s1.desc <=> s2.desc }.to_a
    else
      @synapses = []
    end

    #limit to 5 results
    @synapses = @synapses.slice(0,5)

    render json: autocomplete_synapse_array_json(@synapses)
  end 
end
