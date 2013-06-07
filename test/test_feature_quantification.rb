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
    assert_equal(feature_quant_file.index[["chr1",127573572,"GENE.886"]][0],793452)
    assert_raise RuntimeError do
      feature_quant_file.create_index
    end
  end

  def test_transcript()
    feature_quant_file = FeatureQuantifications.new("test/data/test_feature_quant.txt")
    feature_quant_file.create_index
    transcript = feature_quant_file.transcript("chr1",127573572,"GENE.886")
    assert_equal(transcript,[127573572, 127574769, 127768946, 127770438])
  end

  def test_fpkm_for_transcript()
    feature_quant_file = FeatureQuantifications.new("test/data/test_feature_quant.txt")
    feature_quant_file.create_index
    transcript = feature_quant_file.transcript("chr1",127573572,"GENE.886")
    fc = feature_quant_file.frag_count("chr1",127573572,"GENE.886")
    assert_equal(feature_quant_file.fpkm_value(transcript,fc),12.33915953886203)
  end

end