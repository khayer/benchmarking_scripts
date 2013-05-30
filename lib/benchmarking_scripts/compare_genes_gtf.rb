class CompareGenesGTF < CompareGenes
  def initialize(geneinfo_file,gtf_file)
    super(geneinfo_file)
    @compare_file = GTF.new(gtf_file)
  end
end