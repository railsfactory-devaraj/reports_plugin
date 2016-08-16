module Reports
  module QueriesHelperPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method_chain :column_value, :column_value_custom
      end
    end
    module ClassMethods
    end
    module InstanceMethods
      def column_value_with_column_value_custom(column, issue, value)
        case column.name
        when :id
          link_to issue.new_issue_id.nil? ? value : issue.new_issue_id, issue_path(issue)
        when :subject
          link_to value, issue_path(issue)
        when :parent
          value ? (value.visible? ? link_to_issue(value, :subject => false) : "##{value.id}") : ''
        when :description
          issue.description? ? content_tag('div', textilizable(issue, :description), :class => "wiki") : ''
        when :done_ratio
          progress_bar(value)
        when :relations
          content_tag('span',
            value.to_s(issue) {|other| link_to_issue(other, :subject => false, :tracker => false)}.html_safe,
            :class => value.css_classes_for(issue))
        else
          format_object(value)
        end
      end
    end
  end
end