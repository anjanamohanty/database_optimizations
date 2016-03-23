class ReportsController < ApplicationController
  helper_method :memory_in_mb

  def all_data
    @name = params[:name]
    @start_time = Time.now
    @assembly = Assembly.find_by_name(params[:name])
    @hits = @assembly.hits.order(percent_similarity: :desc)
    @memory_used = memory_in_mb
  end

  def search_view
  end

  def csv_upload
  end

  def csv_success
    @rows = []
    CSV.open(params['csv_file'].tempfile, headers: true) do |c|
      c.each do |line|
        @rows << line['Assembly Name']
        a = Assembly.find_by_name(line['Assembly Name']) || Assembly.create!(name: line['Assembly Name'], run_on: Time.now.to_date)
        s = Sequence.create!(assembly_id: a.id, dna: line['Sequence'], quality: line['Sequence Quality'])
        g = Gene.create!(sequence_id: s.id, dna: line["Gene Sequence"], starting_position: line["Gene Starting Position"], direction: line["Gene Direction"])
        h = Hit.create!(subject_id: g.id, subject_type: "Gene", match_gene_name: line["Hit Name"], match_gene_dna: line["Hit Sequence"], percent_similarity: line['Hit Similarity'])
      end
    end
  end

  def search
    @name = params[:search]
    @start_time = Time.now

    @hits = Hit.joins("JOIN genes ON genes.id = hits.subject_id AND hits.subject_type = 'Gene'")
        .joins("JOIN sequences ON sequences.id = genes.sequence_id")
        .joins("JOIN assemblies ON assemblies.id = sequences.assembly_id")
        .where("assemblies.name LIKE ? OR genes.dna LIKE ? OR hits.match_gene_name LIKE ?",
            params[:search], params[:search], params[:search])
        .order("hits.percent_similarity DESC")

    @memory_used = memory_in_mb
    render 'all_data'
  end

  private def memory_in_mb
    `ps -o rss -p #{$$}`.strip.split.last.to_i / 1024
  end
end
