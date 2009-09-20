class InductionMailer < Merb::MailController
  include Merb::GlobalHelpers
  
  def notify_agenda
    @member = params[:member]
    @organisation_name = params[:organisation_name]
    @founding_meeting_location = params[:founding_meeting_location]
    @founding_meeting_date = params[:founding_meeting_date]
    @founding_meeting_time = params[:founding_meeting_time]
    @founding_member_name = params[:founding_member_name]
    @members = params[:members]
    render_mail
  end
end
