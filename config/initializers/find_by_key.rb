class ActiveRecord::Base

  def self.find_by_key(params)
		key = params.has_key?(:key) ? params[:key] : :id 
  	find_by(Hash[key, params[:id]])
  end
end

class ActiveRecord::Associations::CollectionProxy
  def find_by_key(params)
		key = params.has_key?(:key) ? params[:key] : :id
  	where(Hash[key, params[:id]]).first!
  end	
end
