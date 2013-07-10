class CompareGenesBedGTF < CompareGenes

  def initialize(bed_file,gtf_file)
    super()
    @truth_genefile = Bed.new(bed_file)
    @compare_file = GTF.new(gtf_file)
  end

  attr_accessor

end
