module Reports
	module IssuesControllerPatch
		def self.included(base) # :nodoc:
			base.extend(ClassMethods)
			base.send(:include, InstanceMethods)
			base.class_eval do
				after_filter :save_issue_id, :only => [:create]
			end
		end
		module ClassMethods
		end

		module InstanceMethods
			def save_issue_id
				if @issue.id
 			    	@issue.new_issue_id = Date.today.strftime('%y')+(sprintf '%05d', @issue.id)
 			    	@issue.save
 			    end
			end
		end
	end
end