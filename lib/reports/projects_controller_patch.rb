module Reports
	module ProjectsControllerPatch
		def self.included(base) # :nodoc:
			base.extend(ClassMethods)
			base.send(:include, InstanceMethods)
			base.class_eval do
				# after_filter :save_client_id, :disable_modules, :only => [:create]
				alias_method_chain :create, :create_custom
				alias_method_chain :settings, :settings_custom
			end
		end
		module ClassMethods
		end

		module InstanceMethods
			def create_with_create_custom
			    @issue_custom_fields = IssueCustomField.sorted.to_a
			    @trackers = Tracker.sorted.to_a
			    @project = Project.new
			    @project.safe_attributes = params[:project]
			    if @project.save
			    	if params[:project][:parent_id].nil?
						@project.enabled_module_names = nil
					end
			      unless User.current.admin?
			        @project.add_default_member(User.current)
			      end
			      respond_to do |format|
			        format.html {
			          flash[:notice] = l(:notice_successful_create)
			          if params[:continue]
			            attrs = {:parent_id => @project.parent_id}.reject {|k,v| v.nil?}
			            redirect_to new_project_path(attrs)
			          else
			            redirect_to settings_project_path(@project)
			          end
			        }
			        format.api  { render :action => 'show', :status => :created, :location => url_for(:controller => 'projects', :action => 'show', :id => @project.id) }
			      end
			    else
			      respond_to do |format|
			      	params.merge!(parent_id: params[:project][:parent_id])
			        format.html { render :action => 'new' }
			      end
			    end
			end
			def settings_with_settings_custom
			    @issue_custom_fields = IssueCustomField.sorted.to_a
			    @issue_category ||= IssueCategory.new
			    @member ||= @project.members.new
			    @trackers = Tracker.sorted.to_a
			    @wiki ||= @project.wiki || Wiki.new(:project => @project)
			    params[:parent_id] = @project.parent_id
			end
		end
	end
end