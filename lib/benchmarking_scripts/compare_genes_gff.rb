class CompareGenesGFF < CompareGenes

  def initialize(geneinfo_file,gff_file)
    super(geneinfo_file)
    @compare_file = GFF.new(gff_file)
  end

end