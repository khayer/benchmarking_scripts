require "./test/test_helper"

class TestCompare < Test::Unit::TestCase

  def test_initialize_GFF
    compare_obj = CompareGenesGFF.new("test/data/test_geneinfo.txt","test/data/test.gff")
    assert_kind_of( GFF, compare_obj.compare_file )
    assert_kind_of( GeneInfo, compare_obj.geneinfo )
  end

  def test_statistics_all_GFF()
    compare_obj = CompareGenesGFF.new("test/data/test_geneinfo.txt","test/data/test.gff")
    compare_obj.compare_file.create_index()
    compare_obj.geneinfo.create_index()
    compare_obj.statistics()
    assert_equal(compare_obj.strong_TP,[1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.weak_TP,[3, 1, 0, 0, 2, 0, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.all_FP,[28, 0, 0, 2, 4, 0, 0, 0, 0, 0, 0])
  end

  def test_initialize_GTF
    compare_obj = CompareGenesGTF.new("test/data/test_geneinfo.txt","test/data/test.gtf")
    assert_kind_of( GTF, compare_obj.compare_file )
    assert_kind_of( GeneInfo, compare_obj.geneinfo )
  end

  def test_statistics_all_GTF()
    compare_obj = CompareGenesGTF.new("test/data/test_geneinfo.txt","test/data/test.gtf")
    compare_obj.compare_file.create_index()
    compare_obj.geneinfo.create_index()
    compare_obj.statistics()
    assert_equal(compare_obj.strong_TP,[7, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.weak_TP,[735, 735, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.all_FP,[33, 33, 0, 0, 0, 0, 0, 0, 0, 0, 0])
  end
end