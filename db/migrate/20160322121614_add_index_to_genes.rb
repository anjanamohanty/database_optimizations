class AddIndexToGenes < ActiveRecord::Migration
  def change
    add_index :genes, :sequence_id
    add_index :genes, :dna
  end
end
