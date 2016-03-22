class AddIndexToHits < ActiveRecord::Migration
  def change
    add_index :hits, :subject_id
    add_index :hits, :match_gene_name
  end
end
