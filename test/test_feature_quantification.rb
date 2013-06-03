require "./test/test_helper"

class TestFeatureQuantifications < Test::Unit::TestCase

  def test_initialize()
    gff_file = FeatureQuantifications.new("test/data/test_feature_quant.txt")
    assert_equal("test/data/test_feature_quant.txt",gff_file.filename)
    assert_equal({},gff_file.index)
  end

  def test_create_index()
    gff_file = FeatureQuantifications.new("test_feature_quant.txt")
    gff_file.create_index
    assert_equal(gff_file.index[["chr7",148033815,"scaffold1.path1"]],80)
    assert_raise RuntimeError do
      gff_file.create_index
    end
  end

  def test_transcript()
    gff_file = FeatureQuantifications.new("test_feature_quant.txt")
    gff_file.create_index
    transcript = gff_file.transcript("chr5",136656234,"scaffold15.path1")
    assert_equal(transcript,[136656234,136657366,136665421,136665489,136667769,136667855,136670166,136670267,136674644,136674818])
  end

end