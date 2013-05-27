require "./compare_genes.rb"
require "test/unit"

class TestCompare < Test::Unit::TestCase

  def test_initialize
    compare_obj = CompareGenes.new("test/data/test.gff","test/data/test_geneinfo.txt")
    assert_kind_of( GFF, compare_obj.gff )
    assert_kind_of( GeneInfo, compare_obj.geneinfo )
  end

  def test_statistics()
    compare_obj = CompareGenes.new("test/data/test.gff","test/data/test_geneinfo.txt")
    stats = compare_obj.statistics()
    assert_equal(stats,1)
  end

  def test_statistics_weak()
    compare_obj = CompareGenes.new("test/data/test.gff","test/data/test_geneinfo.txt")
    stats = compare_obj.statistics_weak()
    assert_equal(stats,3)
  end

end