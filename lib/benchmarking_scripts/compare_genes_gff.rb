class CompareGenesGFF < CompareGenes

  def initialize(geneinfo_file,gff_file)
    super()
    @truth_genefile = GeneInfo.new(geneinfo_file)
    @compare_file = GFF.new(gff_file)
  end

end