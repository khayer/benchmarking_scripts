class CompareGenesFQGFF < CompareGenes

  def initialize(feature_quant_file,gff_file)
    super()
    @truth_genefile = FeatureQuantifications.new(feature_quant_file)
    @compare_file = GFF.new(gff_file)
    @strong_TP_by_cov = []
    @weak_TP_by_cov = []
    @all_FP_by_cov = []
    @false_negatives_by_cov = []
  end

  attr_accessor :strong_TP_by_cov, :weak_TP_by_cov, :all_FP_by_cov, :false_negatives_by_cov

end
