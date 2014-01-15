class SpentTimeFormHook < Redmine::Hook::ViewListener
  render_on :view_layouts_base_body_bottom, :partial => '/spent_time_form'    
end

class ViewsLayoutsHook < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context={})
    return stylesheet_link_tag(:spent_time_query, :plugin => 'redmine_save_spent_time_queries')
  end
end
