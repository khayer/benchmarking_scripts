require "./test/test_helper"

class TestFeatureQuantifications < Test::Unit::TestCase

  def test_initialize()
    feature_quant_file = FeatureQuantifications.new("test/data/test_feature_quant.txt")
    assert_equal("test/data/test_feature_quant.txt",feature_quant_file.filename)
    assert_equal({},feature_quant_file.index)
  end
  def test_create_index()
    feature_quant_file = FeatureQuantifications.new("test/data/test_feature_quant.txt")
    feature_quant_file.create_index
    assert_equal(feature_quant_file.index[["chr1",127573572,"GENE.886"]][0],793385)
    assert_raise RuntimeError do
      feature_quant_file.create_index
    end
  end
  def test_transcript()
    feature_quant_file = FeatureQuantifications.new("test/data/test_feature_quant.txt")
    feature_quant_file.create_index
    transcript = feature_quant_file.transcript(["chr1",127573572,"GENE.886"])
    assert_equal(transcript,[127573572, 127574769, 127768946, 127770438])
  end
  def test_fpkm_for_transcript()
    feature_quant_file = FeatureQuantifications.new("test/data/test_feature_quant.txt")
    feature_quant_file.create_index
    transcript = feature_quant_file.transcript(["chr1",127573572,"GENE.886"])
    fc = feature_quant_file.frag_count(["chr1",127573572,"GENE.886"])
    assert_equal(feature_quant_file.fpkm_value(transcript,fc,50),12.33915953886203)
  end
  def test_find_number_of_spliceforms()
    feature_quant_file = FeatureQuantifications.new("test/data/test_feature_quant.txt")
    feature_quant_file.create_index
    #feature_quant_file.calculate_M
    feature_quant_file.calculate_coverage(50)
    feature_quant_file.find_number_of_spliceforms()
    num_splice_forms = feature_quant_file.number_of_spliceforms[["chr1",4763278,"GENE.5"]]
    assert_equal(num_splice_forms,3)
    num_splice_forms = feature_quant_file.number_of_spliceforms[["chr1",12657643,"GENE.53"]]
    assert_equal(num_splice_forms,1)
    num_splice_forms = feature_quant_file.number_of_spliceforms[["chr1",157692093,"GENE.1169"]]
    assert_equal(num_splice_forms,2)
  end
  def test_find_number_of_spliceforms2()
    feature_quant_file = FeatureQuantifications.new("test/data/test_feature_quant.txt")
    feature_quant_file.create_index
    #feature_quant_file.calculate_M
    feature_quant_file.calculate_coverage(50)
    feature_quant_file.find_number_of_spliceforms("test/data/num_spliceform.txt")
    num_splice_forms = feature_quant_file.number_of_spliceforms[["chr1",4763278,"GENE.5"]]
    assert_equal(num_splice_forms,10)
    num_splice_forms = feature_quant_file.number_of_spliceforms[["chr1",12657643,"GENE.53"]]
    assert_equal(num_splice_forms,2)
    num_splice_forms = feature_quant_file.number_of_spliceforms[["chr1",157692093,"GENE.1169"]]
    assert_equal(num_splice_forms,9)
  end
  def test_determine_false_negatives()
    feature_quant_file = FeatureQuantifications.new("test/data/test_feature_quant.txt")
    feature_quant_file.create_index
    feature_quant_file.calculate_coverage(50)
    feature_quant_file.determine_false_negatives
    assert_equal(feature_quant_file.false_negatives[["chr1", 34906803, "GENE.172"]],1309.1195418754473)
  end



end