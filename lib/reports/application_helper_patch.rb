module Reports
	module ApplicationHelperPatch
		def self.included(base) # :nodoc:
			base.extend(ClassMethods)
			base.send(:include, InstanceMethods)
			base.class_eval do
				alias_method_chain :link_to_project, :link_to_project_custom
			end
		end
		module ClassMethods
		end
		module InstanceMethods
			def link_to_project_with_link_to_project_custom(project, options={}, html_options = nil)
			    if project.archived?
			      h(project.name)
			    else
			      link_to "#{project.name} (#{ project.parent_id.nil? ? project.client : project.client_id })",
			        project_url(project, {:only_path => true}.merge(options)),
			        html_options
			    end
			  end
			end
	end
end