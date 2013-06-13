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
    compare_obj.truth_genefile.determine_false_negatives()
    compare_obj.statistics()
    assert_equal(compare_obj.strong_TP,[1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.weak_TP,[3, 1, 0, 0, 2, 0, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.all_FP,[28, 0, 0, 2, 4, 0, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.false_negatives,[9998, 1000, 2000, 3000, 3998, 0, 0, 0, 0, 0, 0])
  end

  def test_initialize_GTF()
    compare_obj = CompareGenesGTF.new("test/data/test_geneinfo.txt","test/data/test.gtf")
    assert_kind_of( GTF, compare_obj.compare_file )
    assert_kind_of( GeneInfo, compare_obj.truth_genefile )
  end

  def test_statistics_all_GTF()
    compare_obj = CompareGenesGTF.new("test/data/test_geneinfo.txt","test/data/test.gtf")
    compare_obj.compare_file.create_index()
    assert_equal(compare_obj.compare_file.index.length,768)
    compare_obj.truth_genefile.create_index()
    compare_obj.truth_genefile.determine_false_negatives()
    compare_obj.statistics()
    assert_equal(compare_obj.strong_TP,[7, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.weak_TP,[735, 735, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.all_FP,[33, 33, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    assert_equal(compare_obj.false_negatives,[9266, 266, 2000, 3000, 4000, 0, 0, 0, 0, 0, 0])
  end

  def test_initialize_FQ_GTF
    compare_obj = CompareGenesFQGTF.new("test/data/test_feature_quant.txt","test/data/test_fq.gtf")
    assert_kind_of( GTF, compare_obj.compare_file )
    assert_kind_of( FeatureQuantifications, compare_obj.truth_genefile )
  end

  def test_statistics_all_FQ_GTF()
    compare_obj = CompareGenesFQGTF.new("test/data/test_feature_quant.txt","test/data/test_fq.gtf")
    compare_obj.compare_file.create_index()
    compare_obj.compare_file.calculate_coverage()
    compare_obj.truth_genefile.create_index()
    compare_obj.truth_genefile.calculate_coverage(50)
    compare_obj.truth_genefile.find_number_of_spliceforms()
    compare_obj.truth_genefile.determine_false_negatives()
    compare_obj.statistics()
    assert_equal(compare_obj.strong_TP,[71, 37, 19, 10, 4, 0, 1, 0, 0, 0, 0])
    assert_equal(compare_obj.weak_TP,[569, 322, 147, 57, 21, 11, 3, 4, 0, 4, 0])
    assert_equal(compare_obj.all_FP,[326, 129, 45, 6, 1, 0, 0, 4, 0, 0, 0])
    assert_equal(compare_obj.false_negatives,[64, 21, 17, 12, 8, 0, 2, 0, 0, 4, 0])
    assert_equal(compare_obj.strong_TP_by_cov,[71, 69, 67, 66, 48, 17, 8, 2])
    assert_equal(compare_obj.weak_TP_by_cov,[569, 527, 432, 255, 108, 33, 15, 2])
    assert_equal(compare_obj.all_FP_by_cov,[185, 108, 87, 54, 24])
    assert_equal(compare_obj.false_negatives_by_cov,[64, 64, 63, 43, 14, 5, 1])
  end

  def test_statistics_all_FQ_GTF_plot()
    compare_obj = CompareGenesFQGTF.new("test/data/test_feature_quant.txt","test/data/test_fq.gtf")
    compare_obj.compare_file.create_index()
    compare_obj.compare_file.calculate_coverage()
    compare_obj.truth_genefile.create_index()
    compare_obj.truth_genefile.calculate_coverage(50)
    compare_obj.truth_genefile.find_number_of_spliceforms()
    compare_obj.statistics_fpkm()
    compare_obj.plot_fpkm("test/data/test.png")
    assert_equal(File.size("test/data/test.png"),4602)
  end

  def test_statistics_all_FQ_GTF_plot_with_M()
    compare_obj = CompareGenesFQGTF.new("test/data/test_feature_quant.txt","test/data/test_fq.gtf")
    compare_obj.compare_file.create_index()
    compare_obj.compare_file.calculate_coverage()
    compare_obj.truth_genefile.create_index()
    compare_obj.truth_genefile.calculate_M()
    compare_obj.truth_genefile.find_number_of_spliceforms()
    compare_obj.truth_genefile.calculate_coverage()
    compare_obj.statistics_fpkm()
    compare_obj.plot_fpkm("test/data/test2.png")
    assert_equal(File.size("test/data/test2.png"),4481)
  end

  def test_initialize_FQ_GFF
    compare_obj = CompareGenesFQGFF.new("test/data/test_feature_quant.txt","test/data/test_fq.gff")
    assert_kind_of( GFF, compare_obj.compare_file )
    assert_kind_of( FeatureQuantifications, compare_obj.truth_genefile )
  end

  def test_statistics_all_FQ_GFF()
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
    assert_equal(compare_obj.all_FP,[7392, 228, 48, 22, 1, 0, 0, 1, 0, 0, 0])
    assert_equal(compare_obj.false_negatives,[462, 240, 131, 48, 24, 5, 5, 1, 0, 8, 0])
    assert_equal(compare_obj.strong_TP_by_cov,[6, 6, 6, 6, 5, 3, 2])
    assert_equal(compare_obj.weak_TP_by_cov,[46, 44, 38, 25, 15, 5, 2])
    assert_equal(compare_obj.all_FP_by_cov,[300, 175, 141, 80, 53, 4])
    assert_equal(compare_obj.false_negatives_by_cov,[462, 462, 458, 274, 107, 33, 14, 2])
  end

end