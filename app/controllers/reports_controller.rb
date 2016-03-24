require 'csv'

class ReportsController < ApplicationController
  helper_method :memory_in_mb

  def all_data
    @name = params[:name]
    @start_time = Time.now
    @assembly = Assembly.find_by_name(params[:name])
    @hits = @assembly.hits.order(percent_similarity: :desc)
    @memory_used = memory_in_mb
    email = params[:email]

    MakeReportJob.perform_later(@name, email)
  end

  def search_view
  end

  def csv_upload
  end

  def csv_success
    UploadCsvJob.perform_later(params['csv_file'].path)
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
