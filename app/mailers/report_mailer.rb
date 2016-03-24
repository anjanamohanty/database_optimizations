class ReportMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.report_mailer.send_name_report.subject
  #
  def send_name_report
    @greeting = "Hi"

    mail to: "anjana.j.mohanty@gmail.com"
  end
end
