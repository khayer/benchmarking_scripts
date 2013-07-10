require "./test/test_helper"

class TestCompareBedGFF < Test::Unit::TestCase

  def test_initialize
    compare_obj = CompareGenesBedGFF.new("test/data/test.bed","test/data/test_bed.gff")
    assert_kind_of( GFF, compare_obj.compare_file )
    assert_kind_of( Bed, compare_obj.truth_genefile )
  end

  def test_statistics()
    compare_obj = CompareGenesBedGFF.new("test/data/test.bed","test/data/test_bed.gff")
    compare_obj.compare_file.create_index()
    compare_obj.truth_genefile.create_index()
    compare_obj.truth_genefile.determine_false_negatives()
    compare_obj.truth_genefile.find_number_of_spliceforms()
    compare_obj.statistics()
    assert_equal(compare_obj.strong_TP,[1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.weak_TP,[2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.all_FP,[1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.false_negatives,[8, 5, 3, 0, 0, 0, 0, 0, 0, 0, 0])
  end

end