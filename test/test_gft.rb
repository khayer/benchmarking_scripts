require "test/unit"
require 'benchmarking_scripts'

class TestGTF < Test::Unit::TestCase

  def test_initialize
    gtf_file = GTF.new("test/data/test.gtf")
    assert_equal("test/data/test.gtf",gtf_file.filename)
    assert_equal({},gtf_file.index)
  end

  def test_create_index()
    gtf_file = GTF.new("test/data/test.gtf")
    gtf_file.create_index
    assert_equal(gtf_file.index[["chr1",4847774,'"CUFF.2.1"']],80)
    assert_raise RuntimeError do
      gtf_file.create_index
    end
  end

  def test_transcript()
    gtf_file = GTF.new("test/data/test.gtf")
    gtf_file.create_index
    transcript = gtf_file.transcript("chr5",136656234,"scaffold15.path1")
    assert_equal(transcript,[136656234,136657366,136665421,136665489,136667769,136667855,136670166,136670267,136674644,136674818])
  end

end