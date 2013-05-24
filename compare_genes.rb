require "./geneinfo.rb"
require "./gff.rb"

class Compare
  def initialize(gff_file,geneinfo_file)
    @gff = GFF.new(gff_file).create_index
    @geneinfo = GeneInfo.new(geneinfo_file).create_index
  end

  attr_accessor :gff, :geneinfo

  def statistics()

  end
end