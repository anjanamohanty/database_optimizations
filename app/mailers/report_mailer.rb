class ReportMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.report_mailer.send_name_report.subject
  #
  def send_name_report(email, attachment_path)
    @greeting = "Hi"

    attachments['report.csv'] = File.read(attachment_path)
    mail to: email
  end
end
