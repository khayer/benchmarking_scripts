class CompareGenesBedGFF < CompareGenes

  def initialize(bed_file,gff_file)
    super()
    @truth_genefile = Bed.new(bed_file)
    @compare_file = GFF.new(gff_file)
  end

  attr_accessor

end
