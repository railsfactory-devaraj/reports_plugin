Redmine::Plugin.register :itechlabs_reports do
  name 'Itechlabs Reports plugin'
  author 'Rails Factory'
  description 'This is a plugin for Redmine report generation'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
end
Redmine::AccessControl.map do |map|
	map.project_module :reports do |map|
    map.permission :add_report, {:reports => [:new, :create]}
  end
end
Redmine::MenuManager.map :top_menu do |menu|
  menu.push :clients, { :controller => 'projects', :action => 'index' }, :caption => 'Clients'
  menu.push :issue, { },:html => {'data-popup-open' => "popup-1",  'href' => "#"},:caption => 'Issues', :if => Proc.new { User.current.logged? }
  menu.push :reports, { :controller => 'reports', :action => 'new' }, :caption => 'Reports', :if => Proc.new { User.current.logged? }
  menu.delete :projects
end
Redmine::MenuManager.map :project_menu do |menu|
	menu.push :report, { :controller => 'reports', :action => 'new', :id => nil }, :param => :project_id, :caption => :label_report_plural,
	          :permission => :add_report
end
Rails.application.config.to_prepare do
  unless ReportsController.include?(Reports::ReportsControllerPatch)
    ReportsController.send(:include, Reports::ReportsControllerPatch)
  end
	unless ProjectsController.include?(Reports::ProjectsControllerPatch)
    ProjectsController.send :include, Reports::ProjectsControllerPatch
  end
  unless IssuesController.include?(Reports::IssuesControllerPatch)
    IssuesController.send :include, Reports::IssuesControllerPatch
  end
	unless Project.include?(Reports::ProjectPatch)
      Project.send(:include, Reports::ProjectPatch)
  end
  unless ApplicationHelper.include?(Reports::ApplicationHelperPatch)
      ApplicationHelper.send(:include, Reports::ApplicationHelperPatch)
  end
  unless QueriesHelper.include?(Reports::QueriesHelperPatch)
      QueriesHelper.send(:include, Reports::QueriesHelperPatch)
  end
  unless IssuesHelper.include?(Reports::IssuesHelperPatch)
	    IssuesHelper.send(:include, Reports::IssuesHelperPatch)
	end
end