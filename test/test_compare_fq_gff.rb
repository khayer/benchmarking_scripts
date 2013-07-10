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
    assert_equal(compare_obj.weak_TP,[106, 61, 23, 17, 2, 2, 0, 0, 0, 1, 0])
    assert_equal(compare_obj.all_FP,[7332, 227, 48, 22, 1, 0, 0, 1, 0, 0, 0])
    assert_equal(compare_obj.false_negatives,[437, 227, 123, 45, 24, 5, 5, 1, 0, 7, 0])
    assert_equal(compare_obj.strong_TP_by_cov,[6, 6, 6, 6, 5, 3, 2])
    assert_equal(compare_obj.weak_TP_by_cov,[106, 76, 65, 41, 22, 7, 2])
    assert_equal(compare_obj.all_FP_by_cov,[299, 176, 149, 80, 53, 4])
    assert_equal(compare_obj.false_negatives_by_cov,[437, 437, 437, 259, 103, 31, 14, 2])
  end

end