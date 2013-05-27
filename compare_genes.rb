require "./geneinfo.rb"
require "./gff.rb"

class CompareGenes
  def initialize(gff_file,geneinfo_file)
    @gff = GFF.new(gff_file)
    @geneinfo = GeneInfo.new(geneinfo_file)
  end

  attr_accessor :gff, :geneinfo

  def statistics()

  end
end