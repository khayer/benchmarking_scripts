require "./test/test_helper"

class TestCompareFQGTF < Test::Unit::TestCase

  def test_initialize()
    compare_obj = CompareGenesFQGTF.new("test/data/test_feature_quant.txt","test/data/test_fq.gtf")
    assert_kind_of( GTF, compare_obj.compare_file )
    assert_kind_of( FeatureQuantifications, compare_obj.truth_genefile )
  end

  def test_statistics()
    compare_obj = CompareGenesFQGTF.new("test/data/test_feature_quant.txt","test/data/test_fq.gtf")
    compare_obj.compare_file.create_index()
    compare_obj.compare_file.calculate_coverage()
    compare_obj.truth_genefile.create_index()
    compare_obj.truth_genefile.calculate_coverage(200)
    compare_obj.truth_genefile.calculate_x_coverage
    compare_obj.truth_genefile.find_number_of_spliceforms()
    compare_obj.truth_genefile.determine_false_negatives(500)
    compare_obj.statistics()
    assert_equal(compare_obj.strong_TP,[70, 36, 17, 10, 6, 0, 1, 0, 0, 0, 0])
    assert_equal(compare_obj.weak_TP,[564, 316, 136, 56, 29, 15, 4, 4, 0, 4, 0])
    assert_equal(compare_obj.all_FP,[125, 85, 28, 7, 1, 1, 2, 1, 0, 0, 0])
    assert_equal(compare_obj.false_negatives,[65, 22, 14, 11, 6, 6, 2, 0, 0, 4, 0])
    assert_equal(compare_obj.strong_TP_by_cov,[70, 67, 63, 36, 13, 6, 1])
    assert_equal(compare_obj.weak_TP_by_cov,[564, 438, 208, 71, 22, 10, 1])
    assert_equal(compare_obj.all_FP_by_cov,[125, 70, 29, 14])
    assert_equal(compare_obj.false_negatives_by_cov,[65, 65, 34, 10, 1])
    assert_equal(compare_obj.weak_TP_by_x_cov,[10, 170, 384])
  end

  def test_statistics_plot()
    compare_obj = CompareGenesFQGTF.new("test/data/test_feature_quant.txt","test/data/test_fq.gtf")
    compare_obj.compare_file.create_index()
    assert_equal(compare_obj.compare_file.index[["chr2",146047732,'"GENE.15706"']],224)
    compare_obj.compare_file.calculate_coverage()
    compare_obj.truth_genefile.create_index()
    compare_obj.truth_genefile.calculate_coverage(237)
    compare_obj.truth_genefile.find_number_of_spliceforms()
    compare_obj.statistics_fpkm()
    compare_obj.plot_fpkm("test/data/test.png")
    assert_equal(compare_obj.fpkm_values[-5],[["chr1", 174153665, "\"CUFF.759.1\""], 0, 2.0306902012])
  end

  def test_statistics_plot_with_M()
    compare_obj = CompareGenesFQGTF.new("test/data/test_feature_quant.txt","test/data/test_fq.gtf")
    compare_obj.compare_file.create_index()

    compare_obj.compare_file.calculate_coverage()
    compare_obj.truth_genefile.create_index()
    compare_obj.truth_genefile.calculate_M()
    compare_obj.truth_genefile.find_number_of_spliceforms()
    compare_obj.truth_genefile.calculate_coverage()
    compare_obj.statistics_fpkm()
    #compare_obj.fpkm_values.each do |values|
    #    puts values.join("\t")
    #    break if values[0] == "chr2"
    #end
    compare_obj.plot_fpkm("test/data/test2.png")
    assert_equal(compare_obj.fpkm_values[-1],[["chr1", 174430377, "\"CUFF.763.1\""], 0, 1.518001898])
  end
end
