require 'gnuplot'
class CompareFPKMFQCUFF < CompareGenes

  def initialize(feature_quant_file,cuff_file)
    super()
    @truth_genefile = FeatureQuantifications.new(feature_quant_file)
    @compare_file = FPKMTrackingFormat.new(cuff_file)
    #@fpkm_values = []
    #@fpkm_values_1_spliceform = []
    #@fpkm_values_else_spliceform = []
    #@strong_TP_by_cov = []
    #@weak_TP_by_cov = []
    #@all_FP_by_cov = []
    #@false_negatives_by_cov = []
    #@strong_TP_by_x_cov = []
    #@weak_TP_by_x_cov = []
    #@all_FP_by_x_cov = []
    #@false_negatives_by_x_cov = []
  end

  #attr_accessor :fpkm_values
end
