module Reports
	module ProjectPatch
		def self.included(base)
	      base.send :include, InstanceMethods
	      base.class_eval do
	        scope :clients, lambda { where(:status => 1, :parent_id => nil) }
	        after_save :save_attributes
	      end
	    end
	    module InstanceMethods
			  def generate_report p,issues,params
			    p.workbook do |wb|
			      wb.add_worksheet(name: "Summary")  do |sheet|
			        styles = wb.styles
			        main_header = styles.add_style(:sz => 14, :b => true, :alignment => {:horizontal => :center,:vertical => :center})
			        header = styles.add_style(:bg_color => 'D3D3D3', :fg_color => '00', :b => true, :border => { :style => :thin, :color => "00" },:alignment => { :horizontal => :center,:vertical => :center })
			        data = styles.add_style(:border => { :style => :thin, :color => "00" },:alignment => { :horizontal => :center,:vertical => :center })
			        sheet.add_row [nil,"Defects summary for project #{self.name} From #{params[:start_date]} to #{params[:end_date]}"],:style=>[nil,main_header],:height => 60
			        sheet.add_row [nil,"Project: #{self.name}"]
			        sheet.add_row [nil,"CLIENT / LICENSEE: #{self.parent.name}"]
			        sheet.add_row
			        sheet.add_row
			        sheet.add_row [nil,'Open', 'Invalid, closed', 'Fixed','To be Re-Tested','Failed retest'], :style => [nil,header,header,header,header,header]
			        issues.each do |issue|
			        	sheet.add_row [nil,issue.status_id == 1 ? (issue.new_issue_id.nil? ? issue.id : issue.new_issue_id) : nil,issue.status_id == 4 ? (issue.new_issue_id.nil? ? issue.id : issue.new_issue_id) : nil,issue.status_id == 5 ? (issue.new_issue_id.nil? ? issue.id : issue.new_issue_id) : nil,issue.status_id == 2 ? (issue.new_issue_id.nil? ? issue.id : issue.new_issue_id) : nil,issue.status_id == 3 ? (issue.new_issue_id.nil? ? issue.id : issue.new_issue_id) : nil],:style =>[nil,data,data,data,data,data]
			        end
			        sheet.add_row
			        sheet.add_row [nil,'Description','High','Medium','Low','Clarifications Needed','Total'], :style=>[nil,header,header,header,header,header,header]
			        sheet.add_row [nil,"Open",issues.where(status_id: 1, priority_id: 4).count,issues.where(status_id: 1, priority_id: 3).count,issues.where(status_id: 1, priority_id: 2).count,issues.where(status_id: 1, priority_id: 1).count,issues.where(status_id: 1).count],:style =>[nil,data,data,data,data,data,data]
			        sheet.add_row [nil,"Fixed",issues.where(status_id: 5, priority_id: 4).count,issues.where(status_id: 5, priority_id: 3).count,issues.where(status_id: 5, priority_id: 2).count,issues.where(status_id: 5, priority_id: 1).count,issues.where(status_id: 5).count],:style =>[nil,data,data,data,data,data,data]
			        sheet.add_row [nil,"Invalid, closed",issues.where(status_id: 4, priority_id: 4).count,issues.where(status_id: 4, priority_id: 3).count,issues.where(status_id: 4, priority_id: 2).count,issues.where(status_id: 4, priority_id: 1).count,issues.where(status_id: 4).count],:style =>[nil,data,data,data,data,data,data]
			        sheet.add_row [nil,"To be Retested",issues.where(status_id: 2, priority_id: 4).count,issues.where(status_id: 2, priority_id: 3).count,issues.where(status_id: 2, priority_id: 2).count,issues.where(status_id: 2, priority_id: 1).count,issues.where(status_id: 2).count],:style =>[nil,data,data,data,data,data,data]
			        sheet.add_row [nil,"Failed retest",issues.where(status_id: 3, priority_id: 4).count,issues.where(status_id: 3, priority_id: 3).count,issues.where(status_id: 3, priority_id: 2).count,issues.where(status_id: 3, priority_id: 1).count,issues.where(status_id: 3).count],:style =>[nil,data,data,data,data,data,data]
			        sheet.add_row [nil,"Total Outstanding",issues.where(priority_id: 4).count,issues.where(priority_id: 3).count,issues.where(priority_id: 2).count,issues.where(priority_id: 1).count,issues.count],:style =>[nil,data,data,data,data,data,data]
			        sheet.add_row
			        sheet.add_row [nil,"Please view 'Details' worksheet for detailed information of the above defects"]
			        sheet.merge_cells("B1:M1")
			        sheet.merge_cells("B2:E2")
			        sheet.merge_cells("B3:E3")
			        sheet.column_widths nil,15,15,15,15,15
			      end
			      wb.add_worksheet(name: "Details")  do |sheet|
			        styles = wb.styles
			        main_header = styles.add_style(:sz => 14, :b => true, :alignment => {:horizontal => :center,:vertical => :center})
			        header = styles.add_style(:bg_color => 'D3D3D3', :fg_color => '00', :b => true, :border => { :style => :thin, :color => "00" },:alignment => { :horizontal => :center,:vertical => :center })
			        re_test = styles.add_style(:bg_color => 'ffff66', :fg_color => '00',:border => { :style => :thin, :color => "00" },:alignment => { :horizontal => :left,:vertical => :top, :wrap_text => true })
			        open = styles.add_style(:bg_color => '66ffff', :fg_color => '00',:border => { :style => :thin, :color => "00" },:alignment => { :horizontal => :left,:vertical => :top, :wrap_text => true })
			        all = styles.add_style(:fg_color => '00',:border => { :style => :thin, :color => "00" },:alignment => { :horizontal => :left,:vertical => :top, :wrap_text => true })
			        sheet.add_row ["Defects details for project #{self.name}"],:style => main_header,:height => 60
			        sheet.add_row ["ID","Category","Sub-Category","Proirity","Description","Comments","Client Comments","Status"],:style => header
			        issues.each do |issue|
			        	comments = ''
			        	client_comments = ''
			        	issue.journals.each do |comment|
			        		if !comment.notes.blank?
				        		if comment.user.groups.where(id: 11).count > 0
				        			client_comments += comment.user.name+"\r" + comment.notes+"\r"
				        		else
				        			comments += comment.user.name+"\r" + comment.notes+"\r"
						        end
					        end
			        	end
			        	sub_category = CustomField.where(name: 'Sub-Category').last
			        	if sub_category && issue.custom_values.where(custom_field_id: sub_category.id).last
			        		@sub_category_val = issue.custom_values.where(custom_field_id: sub_category.id).last.value
			        	else
			        		@sub_category_val = nil
			        	end
			        	if issue.status.name.downcase == 'failed retest'
			        		@style = re_test
			        	elsif issue.status.name.downcase == 'new' || issue.status.name.downcase == 'open'
			        		@style = open
			        	else
			        		@style = all
			        	end
			        	sheet.add_row [(issue.new_issue_id.nil? ? issue.id : issue.new_issue_id),issue.category, @sub_category_val,issue.priority,issue.description,comments,client_comments,issue.status],:style => @style,:height=>250
			        end
			        sheet.merge_cells("A1:M1")
			        sheet.column_widths 15,35,20,15,35,40,40,20,15
			      end
			      wb.add_worksheet(name: "Images")  do |sheet|
			        styles = wb.styles
			        id_style = styles.add_style(:alignment => {:horizontal => :center,:vertical => :top})
			        header = styles.add_style(:b => true, :border => { :style => :thin, :color => "00" },:alignment => { :horizontal => :center,:vertical => :center })
			        sheet.add_row ["Defect Id","Images"],:style => header
			        issues.each_with_index do |issue, j|
				        j = j+1
				        sheet.add_row [(issue.new_issue_id.nil? ? issue.id : issue.new_issue_id)],:style=> id_style,:height=>250,:width => 60
				        issue.attachments.each_with_index do |attachment,i|
				        	if attachment.present?
					        	img = File.expand_path("#{Rails.root.join('files')}/#{attachment.disk_directory}/#{attachment.disk_filename}", __FILE__)
					        	if File.exists?(img)
							        sheet.add_image(:image_src => img, :noSelect => true, :noMove => true, :width => 60) do |image|
							          image.width=300
							          image.height=300
							          image.start_at i+1,j
							        end
							    end
					        end
				        end
				        sheet.column_widths 15,60,60,60,60,60,60,60,60,60,60,60,60,60
			        end
			      end
			    end
			  end
			  def save_attributes
			  	if self.parent_id.nil?
			  			self.update_columns(client: self.identifier.gsub(/[-_]/,'')[0,8].strip, sub_project_count: 0)
 			      else
 			      	self.root.update_columns(sub_project_count: self.root.sub_project_count.nil? ? 1 : self.root.sub_project_count+1)
 			      	self.update_columns(client_id: self.root.identifier.gsub(/[-_]/,'')[0,8].strip+'.'+Date.today.strftime('%y')+(sprintf '%05d', self.root.sub_project_count))
 			    end
			  end
	    end
	end
end