require "./test/test_helper"

class TestGTF < Test::Unit::TestCase

  #def test_initialize
  #  gtf_file = GTF.new("test/data/test.gtf")
  #  assert_equal("test/data/test.gtf",gtf_file.filename)
  #  assert_equal({},gtf_file.index)
  #end
#
  #def test_create_index()
  #  gtf_file = GTF.new("test/data/test.gtf")
  #  gtf_file.create_index
  #  assert_equal(gtf_file.index[["chr1",4847774,'"CUFF.2.1"']],1586)
  #  assert_raise RuntimeError do
  #    gtf_file.create_index
  #  end
  #end
#
  #def test_transcript()
  #  gtf_file = GTF.new("test/data/test.gtf")
  #  gtf_file.create_index
  #  transcript = gtf_file.transcript("chr1",182656179,'"CUFF.670.1"')
  #  assert_equal(transcript,[182656179,182656509,182663296,182663438,182666822,182666981,182668593,182668768,182675201,182675388,182682289,182684324])
  #end
#
  #def test_fpkm_value()
  #  gtf_file = GTF.new("test/data/test.gtf")
  #  gtf_file.create_index
  #  fpkm_value_out = gtf_file.fpkm_value("chr1",182656179,'"CUFF.670.1"')
  #  assert_equal(fpkm_value_out,2.2703220482)
  #end

end