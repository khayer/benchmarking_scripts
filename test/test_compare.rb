require "./compare_genes.rb"
require "test/unit"

class TestCompare < Test::Unit::TestCase

  def test_initialize
    compare_obj = CompareGenes.new("test/data/test.gff","test/data/test_geneinfo.txt")
    assert_kind_of( GFF.new, compare_obj.gff )
    assert_kind_of( GeneInfo.new, compare_obj.geneinfo )
  end

  def test_statistics()

  end


end