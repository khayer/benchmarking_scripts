require "./test/test_helper"

class TestCompareGTF < Test::Unit::TestCase

  def test_initialize()
    compare_obj = CompareGenesGTF.new("test/data/test_geneinfo.txt","test/data/test.gtf")
    assert_kind_of( GTF, compare_obj.compare_file )
    assert_kind_of( GeneInfo, compare_obj.truth_genefile )
  end

  def test_statistics()
    compare_obj = CompareGenesGTF.new("test/data/test_geneinfo.txt","test/data/test.gtf")
    compare_obj.compare_file.create_index()
    assert_equal(compare_obj.compare_file.index.length,768)
    compare_obj.truth_genefile.create_index()
    compare_obj.truth_genefile.determine_false_negatives()
    compare_obj.statistics()
    assert_equal(compare_obj.strong_TP,[7, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.weak_TP,[735, 735, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.all_FP,[28, 28, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.false_negatives,[9266, 266, 2000, 3000, 4000, 0, 0, 0, 0, 0, 0])
  end
end
