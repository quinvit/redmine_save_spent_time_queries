require_dependency 'application_controller'


module SpentTimeQueryHelper
  
  def spent_time_queries
    @queries = SpentTimeQuery.where("user_id = ? OR is_public = ?", User.current.id, true)
    @queries
  end  
  
end


ApplicationController.send(:helper, SpentTimeQueryHelper)