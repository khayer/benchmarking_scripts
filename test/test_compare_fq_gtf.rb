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
    compare_obj.truth_genefile.calculate_coverage(123.597457)
    compare_obj.truth_genefile.find_number_of_spliceforms()
    compare_obj.truth_genefile.determine_false_negatives()
    compare_obj.statistics()
    assert_equal(compare_obj.strong_TP,[72, 37, 20, 10, 4, 0, 1, 0, 0, 0, 0])
    assert_equal(compare_obj.weak_TP,[567, 320, 147, 57, 21, 11, 3, 4, 0, 4, 0])
    assert_equal(compare_obj.all_FP,[328, 130, 46, 6, 1, 0, 0, 4, 0, 0, 0])
    assert_equal(compare_obj.false_negatives,[65, 23, 16, 12, 8, 0, 2, 0, 0, 4, 0])
    assert_equal(compare_obj.strong_TP_by_cov,[72, 67, 66, 50, 21, 8, 2])
    assert_equal(compare_obj.weak_TP_by_cov,[567, 438, 267, 121, 38, 16, 3])
    assert_equal(compare_obj.all_FP_by_cov,[187, 89, 51, 26, 7])
    assert_equal(compare_obj.false_negatives_by_cov,[65, 65, 44, 17, 5, 1])
  end

  def test_statistics_plot()
    compare_obj = CompareGenesFQGTF.new("test/data/test_feature_quant.txt","test/data/test_fq.gtf")
    compare_obj.compare_file.create_index()
    compare_obj.compare_file.calculate_coverage()
    compare_obj.truth_genefile.create_index()
    compare_obj.truth_genefile.calculate_coverage(123.597457)
    compare_obj.truth_genefile.find_number_of_spliceforms()
    compare_obj.statistics_fpkm()
    compare_obj.plot_fpkm("test/data/test.png")
    assert_equal(File.size("test/data/test.png"),5805)
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
    compare_obj.plot_fpkm("test/data/test2.png")
    assert_equal(File.size("test/data/test2.png"),4739)
  end
end
