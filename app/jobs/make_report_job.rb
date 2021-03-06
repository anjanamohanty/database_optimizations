class MakeReportJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    start_time = Time.now
    assembly = Assembly.find_by_name(args[0])
    hits = assembly.hits.order(percent_similarity: :desc)

    file_path = Rails.root.join("reports", "report_#{args[0]}_#{start_time}.csv")
    CSV.open(file_path, "w") do |csv|
      count = 1
      csv << ["Matching Gene Name", "Matching DNA", "Percent Similarity"]
      hits.each do |h|
        csv << [h.match_gene_name, h.match_gene_dna, h.percent_similarity]
        break if count > 99
        count += 1
      end
    end

    ReportMailer.send_name_report(args[1], file_path).deliver_now
  end
end
