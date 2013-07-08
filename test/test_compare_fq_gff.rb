require "./test/test_helper"

class TestCompareFQGFF < Test::Unit::TestCase

  def test_initialize
    compare_obj = CompareGenesFQGFF.new("test/data/test_feature_quant.txt","test/data/test_fq.gff")
    assert_kind_of( GFF, compare_obj.compare_file )
    assert_kind_of( FeatureQuantifications, compare_obj.truth_genefile )
  end

  def test_statistics()
    compare_obj = CompareGenesFQGFF.new("test/data/test_feature_quant.txt","test/data/test_fq.gff")
    compare_obj.compare_file.create_index()
    compare_obj.truth_genefile.create_index()
    assert_raise RuntimeError do
      compare_obj.truth_genefile.calculate_coverage()
    end
    compare_obj.truth_genefile.calculate_coverage(50)
    compare_obj.truth_genefile.determine_false_negatives()
    compare_obj.truth_genefile.find_number_of_spliceforms()
    compare_obj.statistics()
    assert_equal(compare_obj.strong_TP,[6, 4, 1, 1, 0, 0, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.weak_TP,[46, 22, 11, 11, 0, 2, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.all_FP,[7392, 229, 47, 22, 1, 0, 0, 1, 0, 0, 0])
    assert_equal(compare_obj.false_negatives,[462, 241, 130, 48, 24, 5, 5, 1, 0, 8, 0])
    assert_equal(compare_obj.strong_TP_by_cov,[6, 6, 6, 6, 5, 3, 2])
    assert_equal(compare_obj.weak_TP_by_cov,[46, 44, 40, 25, 16, 5, 2])
    assert_equal(compare_obj.all_FP_by_cov,[300, 175, 141, 79, 53, 4])
    assert_equal(compare_obj.false_negatives_by_cov,[462, 462, 457, 273, 107, 33, 14, 2])
  end

end