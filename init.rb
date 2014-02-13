require 'redmine'
require 'spent_time_form_hook'
require 'spent_time_patch'

Redmine::Plugin.register :redmine_save_spent_time_queries do
  name 'Redmine Save Spent Time Queries plugin'
  author 'Qui'
  description 'This plugin allow to save spent time queries'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
    
  menu :top_menu, :spent_time_query, { :controller => 'timelog', :action => 'index' }, :caption => 'Spent time queries '

end
