require 'redmine'
require 'spent_time_form_hook'
require 'spent_time_application_controller_patch'

Redmine::Plugin.register :redmine_save_spent_time_queries do
  name 'Redmine Save Spent Time Queries plugin'
  author 'Qui'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'https://github.com/quinvit/redmine_save_spent_time_queries'
  author_url 'http://www.codeproject.com/Members/quiit'
    
  menu :top_menu, :spent_time_query, { :controller => 'timelog', :action => 'index' }, :caption => 'Spent time queries '

end
