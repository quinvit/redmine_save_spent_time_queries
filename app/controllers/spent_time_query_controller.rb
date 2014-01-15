class SpentTimeQueryController < ApplicationController
  
  before_filter :authorize, :except => [:new, :index, :delete, :save]
  before_filter :authorize_global, :only => [:new, :index, :delete, :save]

  rescue_from Query::StatementInvalid, :with => :query_statement_invalid

  include SpentTimeQueryHelper

  def index
    project_id = params[:id].to_i
    @project = project_id == 0 ? nil : Project.find(project_id) 
    @queries = SpentTimeQuery.find_all_by_user_id(User.current.id)
  end

  def new
    
  end
  
  def delete
    query = SpentTimeQuery.find(params[:query_id])
    query.delete
    
    project_id = params[:id].to_i
    @project = project_id == 0 ? nil : Project.find(project_id) 
    redirect_to :action => 'index', :id => @project
  end
  
  def save
    project_id = params[:id].to_i
    @project = project_id == 0 ? nil : Project.find(project_id)
    
    if @project == nil 
        value = '/time_entries?' + params[:query][:value]
    else
        value = '/projects/' + @project.identifier + '/time_entries?' + params[:query][:value]
    end
    
    query = SpentTimeQuery.create(
              :name => params[:query][:name], 
              :query => value, 
              :is_public => params[:query][:is_public],
              :user_id => User.current.id
              )

    redirect_to :action => 'index'
  end

end
