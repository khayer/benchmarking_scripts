require "test/unit"
require 'benchmarking_scripts'

class TestCompare < Test::Unit::TestCase

  def test_initialize
    compare_obj = CompareGenes.new("test/data/test.gff","test/data/test_geneinfo.txt")
    assert_kind_of( GFF, compare_obj.gff )
    assert_kind_of( GeneInfo, compare_obj.geneinfo )
  end

  def test_statistics_all()
    compare_obj = CompareGenes.new("test/data/test.gff","test/data/test_geneinfo.txt")
    compare_obj.gff.create_index()
    compare_obj.geneinfo.create_index()
    compare_obj.statistics()
    assert_equal(compare_obj.strong_TP,[1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.weak_TP,[3, 1, 0, 0, 2, 0, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.all_FP,[36, 0, 0, 2, 6, 0, 0, 0, 0, 0, 0])
  end
end