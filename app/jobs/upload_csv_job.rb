class UploadCsvJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    CSV.open(args[0], headers: true) do |c|
      c.each do |line|
        a = Assembly.find_by_name(line['Assembly Name']) || Assembly.create!(name: line['Assembly Name'], run_on: Time.now.to_date)
        s = Sequence.create!(assembly_id: a.id, dna: line['Sequence'], quality: line['Sequence Quality'])
        g = Gene.create!(sequence_id: s.id, dna: line["Gene Sequence"], starting_position: line["Gene Starting Position"], direction: line["Gene Direction"])
        h = Hit.create!(subject_id: g.id, subject_type: "Gene", match_gene_name: line["Hit Name"], match_gene_dna: line["Hit Sequence"], percent_similarity: line['Hit Similarity'])
      end
    end
  end
end
