require_dependency 'application_controller'
require_dependency 'timelog_helper'
require_dependency 'timelog_controller'
require_dependency 'time_entry_query'
require_dependency 'sort_helper'
require_dependency 'custom_fields_helper'
require_dependency 'queries_helper' 
require_dependency '../lib/redmine/pagination' 

module SpentTimeQueryHelper
  
  def spent_time_queries
    @queries = SpentTimeQuery.where("user_id = ? OR is_public = ?", User.current.id, true)
    @queries
  end  
      
  def can_edit_current_query    
    @query_editable = @current_query.nil? || @current_query.user_id == User.current.id || User.current.admin
    @query_editable    
  end     
  
end

module TimelogHelperPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
    
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development

      alias_method_chain :format_criteria_value, :add_issue_description
    end    
    
  end

  module InstanceMethods      
    
    def format_criteria_value_with_add_issue_description(criteria_options, value)
      if value.blank?
        "[#{l(:label_none)}]"
      elsif k = criteria_options[:klass]
        obj = k.find_by_id(value.to_i)
        if obj.is_a?(Issue)
          obj.visible? ? 
            # "#{obj.tracker} ##{obj.id}: #{obj.subject} <div class='issue_short_description'>Start date: <b>#{obj.start_date}</b>, Due date: <b>#{obj.due_date}</b>, Est. time: <b>#{obj.estimated_hours}</b></div>" 
            "#{obj.tracker} ##{obj.id} (#{obj.start_date} => #{obj.due_date} ~#{obj.estimated_hours}): #{obj.subject}"
             : 
             "##{obj.id}"
        else
          obj
        end
      else
        format_value(value, criteria_options[:format])
      end
    end 
    
  end
end

module TimelogControllerPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
    
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development

      alias_method_chain :index, :group
      alias_method_chain :report, :group
    end    
  end

  module InstanceMethods
    
    include Redmine::Pagination    
    
    def report_with_group
      if !@issue.nil? || !@project.nil?
        report_without_group
        return
      end
      
      @current_query = nil
      begin
        @current_query = SpentTimeQuery.find_by_name(CGI.unescape(params[:v][:query]))
      rescue
      end     
      
      report_without_group       
    end
    
    def index_with_group
      
      if !@issue.nil? || !@project.nil?
        index_without_group
        return
      end
      
      @current_query = nil
      begin
        @current_query = SpentTimeQuery.find_by_name(CGI.unescape(params[:v][:query]))
      rescue
      end      
      
      default_params = {"f"=>["spent_on", ""], "op"=>{"spent_on"=>"w"}, "c"=>["project", "spent_on", "user", "activity", "issue", "comments", "hours"], "query"=>{"group_by"=>"user"}}
      if params[:spent_on].nil? && params[:op].nil? && params[:c].nil? && params[:query].nil?
        params.merge!(default_params)
      end
      
      @query = TimeEntryQuery.build_from_params(params, :project => @project, :name => '_')      
      
      scope = time_entry_scope
  
      sort_init(@query.sort_criteria.empty? ? [['spent_on', 'desc']] : @query.sort_criteria)
      sort_update(@query.sortable_columns)
      
      group_columns = {"project" => 'time_entries.project_id', "user" => 'time_entries.user_id', "activity" => 'time_entries.activity_id'}            
  
      respond_to do |format|
        format.html {
          # Paginate results
          @entry_count = scope.count
          @entry_pages = Paginator.new @entry_count, per_page_option, params['page']
          @entries = scope.all(
            :include => [:project, :activity, :user, {:issue => :tracker}],
            :order => [group_columns[@query.group_by], sort_clause],            
            :limit  =>  @entry_pages.per_page,
            :offset =>  @entry_pages.offset
          )
          
          @time_entry_count_by_group = @query.time_entry_count_by_group
          @total_hours = scope.sum(:hours).to_f
  
          render :layout => !request.xhr?
        }
        format.api  {
          @entry_count = scope.count
          @offset, @limit = api_offset_and_limit
          @entries = scope.all(
            :include => [:project, :activity, :user, {:issue => :tracker}],
            :order => sort_clause,            
            :limit  => @limit,
            :offset => @offset
          )
        }
        format.atom {
          entries = scope.all(
            :include => [:project, :activity, :user, {:issue => :tracker}],
            :order => "#{TimeEntry.table_name}.created_on DESC",            
            :limit => Setting.feeds_limit.to_i
          )
          render_feed(entries, :title => l(:label_spent_time))
        }
        format.csv {
          # Export all entries
          @entries = scope.all(
            :include => [:project, :activity, :user, {:issue => [:tracker, :assigned_to, :priority]}],
            :order => sort_clause
          )
          send_data(query_to_csv(@entries, @query, params), :type => 'text/csv; header=present', :filename => 'timelog.csv')
        }
      end
    end 
        
  end
end


module TimeEntryQueryPatch
  
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
    
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development

      alias_method_chain :initialize_available_filters, :user_group
    end    
    
  end  
  
  module InstanceMethods     
    
    def initialize_available_filters_with_user_group
      group_values = Group.all.collect {|g| [g.name, g.id.to_s] }
      add_available_filter("member_of_group",
        :type => :list_optional, :values => group_values, :name => "User's group"
      ) unless group_values.empty?     
      
      initialize_available_filters_without_user_group
    end
    
    def sql_for_member_of_group_field(field, operator, value)
      if operator == '*' # Any group
        groups = Group.all
        operator = '=' # Override the operator since we want to find by assigned_to
      elsif operator == "!*"
        groups = Group.all
        operator = '!' # Override the operator since we want to find by assigned_to
      else
        groups = Group.find_all_by_id(value)
      end
      groups ||= []
    
      members_of_groups = groups.inject([]) {|user_ids, group|
        user_ids + group.user_ids + [group.id]
      }.uniq.compact.sort.collect(&:to_s)
    
      '(' + sql_for_field("user_id", operator, members_of_groups, TimeEntry.table_name, "user_id", false) + ')'
    end    
    
    # Returns the time spent sum by group or nil if query is not grouped
    def time_entry_count_by_group
      r = nil
      if grouped?
        begin
          # Rails3 will raise an (unexpected) RecordNotFound if there's only a nil group value
          r = TimeEntry.sum(:hours, :group => group_by_statement, :include => [:status, :project], :conditions => statement)
        rescue ActiveRecord::RecordNotFound
        
        end
        c = group_by_column
        if c.is_a?(QueryCustomFieldColumn)
          r = r.keys.inject({}) {|h, k| h[c.custom_field.cast_value(k)] = r[k]; h}
        end
      end
      r
    rescue ::ActiveRecord::StatementInvalid => e
      raise StatementInvalid.new(e.message)
    end
  end
end

TimeEntryQuery.send(:include, TimeEntryQueryPatch)
TimelogController.send(:include, TimelogControllerPatch)
TimelogController.send(:helper, SpentTimeQueryHelper)
ApplicationController.send(:helper, SpentTimeQueryHelper)
TimelogHelper.send(:include, TimelogHelperPatch)