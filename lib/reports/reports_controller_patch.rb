module Reports
	module ReportsControllerPatch
		def self.included(base) # :nodoc:
			base.extend(ClassMethods)
			base.send(:include, InstanceMethods)

			base.class_eval do
				before_filter :find_project, :authorize, :find_issue_statuses, except: [:new, :get_projects, :get_users, :get_report, :get_clients, :get_client_projetcs]
			end
		end
		module ClassMethods
		end

		module InstanceMethods

		 def new
				@project = Project.where(identifier: params[:project_id]).last
				render :layout => !request.xhr?
			end

			def get_projects
				@client = Project.find(params[:client_id])
				if params[:project_status] != '0'
					@subprojects = @client.descendants.visible.where(status: params[:project_status].to_i)
				else
					@subprojects = @client.descendants.visible
				end
				@projects = @subprojects.map{ |u| [u.name+" - (#{u.client_id})", u.id.to_s] }.sort {|a,b| a[0] <=> b[0]}
				render 'new.js.erb'
			end

			def get_users
				@project = Project.find(params[:project_id])
				@users = @project.users.map{ |u| [u.name, u.id.to_s] }
				User.where(admin: true).each {|u| @users << [u.name, u.id.to_s]}
				@users = @users.unshift(['All', 0]).sort {|a,b| a[0] <=> b[0]}
				@categories = @project.issue_categories.map{ |u| [u.name, u.id.to_s] }.unshift(['All', 0]).sort {|a,b| a[0] <=> b[0]}
				render 'new.js.erb'
			end

			def get_report
				reviewed = CustomField.where(name: 'Reviewed').last
				if !report_params.has_value?('') && reviewed
					@project = Project.find(params[:project])
					@issues = @project.issues.where(created_on: report_params[:start_date].to_datetime.beginning_of_day..report_params[:end_date].to_datetime.end_of_day).joins(:custom_values).where(:custom_values => {:customized_type => 'Issue', :custom_field_id =>  reviewed.id, :value => '1'})
					if params['issue_status'] != '0'
						@issues = @issues.where(status_id: params['issue_status'])
					end
					if params[:user] != '0'
						@issues = @issues.where(author_id: params[:user])
					end
					if params[:category] != '0'
						@issues = @issues.where(category_id: params[:category])
					end
					p = Axlsx::Package.new
					@project.generate_report p,@issues,params
					begin
						temp = Tempfile.new("report.xlsx")
						p.serialize temp.path
						respond_to do |format|
							format.xlsx {send_file temp.path, :filename => "report.xlsx", :type => "application/xlsx", :disposition => 'attachment'}
					  end
					ensure
						temp.close
					end
				else
					if params[:project_id].blank?
						@url = '/reports/new'
					else
						@url = '/reports/new?project_id='+params[:project_id]
					end
					if reviewed
						@message = "No Reviewed custom field"
					else
						@message = "Fill mandatory fields "
					end
					redirect_to @url, alert: @message
				end
			end

			def get_clients
			    render json: Project.clients.where("name LIKE ?", "%#{params[:term]}%").map{|client| {"id" => client.id, "name" => client.name+" (#{client.client_id})"}}
			end
			def get_client_projetcs
				@client = Project.find(params[:client_id])
				@subprojects = @client.descendants.visible
				@projects = @subprojects.map{ |u| [u.name+" - (#{u.client_id})", u.identifier] }.sort {|a,b| a[0] <=> b[0]}
				render 'get_client_projetcs.js.erb'
			end
			private
			def report_params
				params.permit(:user, :category, :reviewed, :start_date, :end_date,:project,:issue_status)
			end
		end
	end
end