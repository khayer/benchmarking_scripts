class TestCompareGFF < Test::Unit::TestCase

  def test_initialize_GFF
    compare_obj = CompareGenesGFF.new("test/data/test_geneinfo.txt","test/data/test.gff")
    assert_kind_of( GFF, compare_obj.compare_file )
    assert_kind_of( GeneInfo, compare_obj.truth_genefile )
  end

  def test_statistics_all_GFF()
    compare_obj = CompareGenesGFF.new("test/data/test_geneinfo.txt","test/data/test.gff")
    compare_obj.compare_file.create_index()
    compare_obj.truth_genefile.create_index()
    compare_obj.truth_genefile.determine_false_negatives()
    compare_obj.statistics()
    assert_equal(compare_obj.strong_TP,[1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.weak_TP,[3, 1, 0, 0, 2, 0, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.all_FP,[28, 0, 0, 2, 4, 0, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.false_negatives,[9998, 1000, 2000, 3000, 3998, 0, 0, 0, 0, 0, 0])
  end

  def test_initialize_GFF
    compare_obj = CompareGenesGFF.new("test/data/test_geneinfo_short.txt","test/data/test_short.gff")
    assert_kind_of( GFF, compare_obj.compare_file )
    assert_kind_of( GeneInfo, compare_obj.truth_genefile )
  end

  def test_statistics_all_GFF()
    compare_obj = CompareGenesGFF.new("test/data/test_geneinfo_short.txt","test/data/test_short.gff")
    compare_obj.compare_file.create_index()
    compare_obj.truth_genefile.create_index()
    compare_obj.truth_genefile.determine_false_negatives()
    compare_obj.statistics()
    assert_equal(compare_obj.strong_TP,[1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.weak_TP,[1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.all_FP,[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.false_negatives,[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
  end

end