require "./test/test_helper"

class TestFeatureQuantifications < Test::Unit::TestCase

  def test_initialize()
    feature_quant_file = FeatureQuantifications.new("test/data/test_feature_quant.txt")
    assert_equal("test/data/test_feature_quant.txt",feature_quant_file.filename)
    assert_equal({},gff_file.index)
  end

  def test_create_index()
    feature_quant_file = FeatureQuantifications.new("test_feature_quant.txt")
    feature_quant_file.create_index
    assert_equal(feature_quant_file.index[["chr1",127573573,"GENE.886"]],80)
    assert_raise RuntimeError do
      feature_quant_file.create_index
    end
  end

  def test_transcript()
    feature_quant_file = FeatureQuantifications.new("test_feature_quant.txt")
    feature_quant_file.create_index
    transcript = feature_quant_file.transcript("chr1",127573573,"GENE.886")
    assert_equal(transcript,[136656234,136657366,136665421,136665489,136667769,136667855,136670166,136670267,136674644,136674818])
  end

end