require "./test/test_helper"

class TestCompare < Test::Unit::TestCase

  #def test_initialize_GTF()
  #  compare_obj = CompareGenesGTF.new("test/data/test_geneinfo.txt","test/data/test.gtf")
  #  assert_kind_of( GTF, compare_obj.compare_file )
  #  assert_kind_of( GeneInfo, compare_obj.truth_genefile )
  #end
#
  #def test_statistics_all_GTF()
  #  compare_obj = CompareGenesGTF.new("test/data/test_geneinfo.txt","test/data/test.gtf")
  #  compare_obj.compare_file.create_index()
  #  assert_equal(compare_obj.compare_file.index.length,768)
  #  compare_obj.truth_genefile.create_index()
  #  compare_obj.truth_genefile.determine_false_negatives()
  #  compare_obj.statistics()
  #  assert_equal(compare_obj.strong_TP,[7, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0])
  #  assert_equal(compare_obj.weak_TP,[735, 735, 0, 0, 0, 0, 0, 0, 0, 0, 0])
  #  assert_equal(compare_obj.all_FP,[33, 33, 0, 0, 0, 0, 0, 0, 0, 0, 0])
  #  assert_equal(compare_obj.false_negatives,[9266, 266, 2000, 3000, 4000, 0, 0, 0, 0, 0, 0])
  #end
#
  #def test_initialize_FQ_GTF
  #  compare_obj = CompareGenesFQGTF.new("test/data/test_feature_quant.txt","test/data/test_fq.gtf")
  #  assert_kind_of( GTF, compare_obj.compare_file )
  #  assert_kind_of( FeatureQuantifications, compare_obj.truth_genefile )
  #end
#
  #def test_statistics_all_FQ_GTF()
  #  compare_obj = CompareGenesFQGTF.new("test/data/test_feature_quant.txt","test/data/test_fq.gtf")
  #  compare_obj.compare_file.create_index()
  #  compare_obj.compare_file.calculate_coverage()
  #  compare_obj.truth_genefile.create_index()
  #  compare_obj.truth_genefile.calculate_coverage(50)
  #  compare_obj.truth_genefile.find_number_of_spliceforms()
  #  compare_obj.truth_genefile.determine_false_negatives()
  #  compare_obj.statistics()
  #  assert_equal(compare_obj.strong_TP,[72, 37, 20, 10, 4, 0, 1, 0, 0, 0, 0])
  #  assert_equal(compare_obj.weak_TP,[567, 320, 147, 57, 21, 11, 3, 4, 0, 4, 0])
  #  assert_equal(compare_obj.all_FP,[328, 130, 46, 6, 1, 0, 0, 4, 0, 0, 0])
  #  assert_equal(compare_obj.false_negatives,[65, 23, 16, 12, 8, 0, 2, 0, 0, 4, 0])
  #  assert_equal(compare_obj.strong_TP_by_cov,[72, 69, 67, 66, 48, 17, 8, 2])
  #  assert_equal(compare_obj.weak_TP_by_cov,[567, 524, 430, 253, 108, 33, 15, 2])
  #  assert_equal(compare_obj.all_FP_by_cov,[187, 106, 85, 51, 24])
  #  assert_equal(compare_obj.false_negatives_by_cov,[65, 65, 64, 44, 14, 5, 1])
  #end
#
  #def test_statistics_all_FQ_GTF_plot()
  #  compare_obj = CompareGenesFQGTF.new("test/data/test_feature_quant.txt","test/data/test_fq.gtf")
  #  compare_obj.compare_file.create_index()
  #  compare_obj.compare_file.calculate_coverage()
  #  compare_obj.truth_genefile.create_index()
  #  compare_obj.truth_genefile.calculate_coverage(50)
  #  compare_obj.truth_genefile.find_number_of_spliceforms()
  #  compare_obj.statistics_fpkm()
  #  compare_obj.plot_fpkm("test/data/test.png")
  #  assert_equal(File.size("test/data/test.png"),5736)
  #end
#
  #def test_statistics_all_FQ_GTF_plot_with_M()
  #  compare_obj = CompareGenesFQGTF.new("test/data/test_feature_quant.txt","test/data/test_fq.gtf")
  #  compare_obj.compare_file.create_index()
  #  compare_obj.compare_file.calculate_coverage()
  #  compare_obj.truth_genefile.create_index()
  #  compare_obj.truth_genefile.calculate_M()
  #  compare_obj.truth_genefile.find_number_of_spliceforms()
  #  compare_obj.truth_genefile.calculate_coverage()
  #  compare_obj.statistics_fpkm()
  #  compare_obj.plot_fpkm("test/data/test2.png")
  #  assert_equal(File.size("test/data/test2.png"),4871)
  #end
#
  #def test_initialize_FQ_GFF
  #  compare_obj = CompareGenesFQGFF.new("test/data/test_feature_quant.txt","test/data/test_fq.gff")
  #  assert_kind_of( GFF, compare_obj.compare_file )
  #  assert_kind_of( FeatureQuantifications, compare_obj.truth_genefile )
  #end
#
  #def test_statistics_all_FQ_GFF()
  #  compare_obj = CompareGenesFQGFF.new("test/data/test_feature_quant.txt","test/data/test_fq.gff")
  #  compare_obj.compare_file.create_index()
  #  compare_obj.truth_genefile.create_index()
  #  assert_raise RuntimeError do
  #    compare_obj.truth_genefile.calculate_coverage()
  #  end
  #  compare_obj.truth_genefile.calculate_coverage(50)
  #  compare_obj.truth_genefile.determine_false_negatives()
  #  compare_obj.truth_genefile.find_number_of_spliceforms()
  #  compare_obj.statistics()
  #  assert_equal(compare_obj.strong_TP,[6, 4, 1, 1, 0, 0, 0, 0, 0, 0, 0])
  #  assert_equal(compare_obj.weak_TP,[46, 22, 11, 11, 0, 2, 0, 0, 0, 0, 0])
  #  assert_equal(compare_obj.all_FP,[7392, 229, 47, 22, 1, 0, 0, 1, 0, 0, 0])
  #  assert_equal(compare_obj.false_negatives,[462, 241, 130, 48, 24, 5, 5, 1, 0, 8, 0])
  #  assert_equal(compare_obj.strong_TP_by_cov,[6, 6, 6, 6, 5, 3, 2])
  #  assert_equal(compare_obj.weak_TP_by_cov,[46, 44, 38, 25, 15, 5, 2])
  #  assert_equal(compare_obj.all_FP_by_cov,[300, 175, 141, 79, 53, 4])
  #  assert_equal(compare_obj.false_negatives_by_cov,[462, 462, 457, 273, 107, 33, 14, 2])
  #end

end