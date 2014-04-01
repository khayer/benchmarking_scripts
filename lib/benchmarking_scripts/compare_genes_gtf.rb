class CompareGenesGTF < CompareGenes

  def initialize(geneinfo_file,gtf_file)
    super()
    @truth_genefile = GeneInfo.new(geneinfo_file)
    @compare_file = GTF.new(gtf_file)
    @false_positives_per_gene = []
    @already_counted = []
  end



end