require "./test/test_helper"

class TestCompare < Test::Unit::TestCase

  def test_initialize_GFF
    compare_obj = CompareGenesGFF.new("test/data/test_geneinfo.txt","test/data/test.gff")
    assert_kind_of( GFF, compare_obj.compare_file )
    assert_kind_of( GeneInfo, compare_obj.truth_genefile )
  end

  def test_statistics_all_GFF()
    compare_obj = CompareGenesGFF.new("test/data/test_geneinfo.txt","test/data/test.gff")
    compare_obj.compare_file.create_index()
    compare_obj.truth_genefile.create_index()
    compare_obj.statistics()
    assert_equal(compare_obj.strong_TP,[1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.weak_TP,[3, 1, 0, 0, 2, 0, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.all_FP,[28, 0, 0, 2, 4, 0, 0, 0, 0, 0, 0])
  end

  def test_initialize_GTF()
    compare_obj = CompareGenesGTF.new("test/data/test_geneinfo.txt","test/data/test.gtf")
    assert_kind_of( GTF, compare_obj.compare_file )
    assert_kind_of( GeneInfo, compare_obj.truth_genefile )
  end

  def test_statistics_all_GTF()
    compare_obj = CompareGenesGTF.new("test/data/test_geneinfo.txt","test/data/test.gtf")
    compare_obj.compare_file.create_index()
    compare_obj.truth_genefile.create_index()
    compare_obj.statistics()
    assert_equal(compare_obj.strong_TP,[7, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.weak_TP,[735, 735, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.all_FP,[33, 33, 0, 0, 0, 0, 0, 0, 0, 0, 0])
  end

  def test_initialize_FQ_GTF
    compare_obj = CompareGenesFQGTF.new("test/data/test_feature_quant.txt","test/data/test_fq.gtf")
    assert_kind_of( GTF, compare_obj.compare_file )
    assert_kind_of( FeatureQuantifications, compare_obj.truth_genefile )
  end

  def test_statistics_all_FQ_GTF()
    compare_obj = CompareGenesFQGTF.new("test/data/test_feature_quant.txt","test/data/test_fq.gtf")
    compare_obj.compare_file.create_index()
    compare_obj.truth_genefile.create_index()
    compare_obj.truth_genefile.find_number_of_spliceforms()
    compare_obj.statistics()
    assert_equal(compare_obj.strong_TP,[71, 37, 19, 10, 4, 0, 1, 0, 0, 0, 0])
    assert_equal(compare_obj.weak_TP,[569, 322, 147, 57, 21, 11, 3, 4, 0, 4, 0])
    assert_equal(compare_obj.all_FP,[326, 129, 45, 6, 1, 0, 0, 4, 0, 0, 0])
  end

  def test_statistics_all_FQ_GTF_plot()
    compare_obj = CompareGenesFQGTF.new("test/data/test_feature_quant.txt","test/data/test_fq.gtf")
    compare_obj.compare_file.create_index()
    compare_obj.truth_genefile.create_index()
    compare_obj.statistics_fpkm()
    compare_obj.plot_fpkm("test/data/test.png")
    assert_equal(File.size("test/data/test.png"),3048)
  end

end