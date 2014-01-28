class CompareGenesBedBed < CompareGenes

  def initialize(bed_file,bed_file)
    super()
    @truth_genefile = Bed.new(bed_file)
    @compare_file = Bed.new(bed_file)
  end

  attr_accessor

end