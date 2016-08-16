module Reports
	module IssuesHelperPatch
	  def self.included(base)
		  base.extend(ClassMethods)
	      base.send(:include, InstanceMethods)
	      base.class_eval do
	        alias_method_chain :issue_heading, :issue_heading_custom
	      end
	  end
      module ClassMethods
	  end
	  module InstanceMethods
	  	def issue_heading_with_issue_heading_custom(issue)
			h("#{issue.tracker} ##{issue.new_issue_id.nil? ? issue.id : issue.new_issue_id}")
		end
	  end
	end
end