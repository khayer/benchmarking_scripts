require "test/unit"
require 'benchmarking_scripts'

class TestGeneInfo < Test::Unit::TestCase

  def test_initialize
    geneinfo_info = GeneInfo.new("test/data/test_geneinfo.txt")
    assert_equal("test/data/test_geneinfo.txt",geneinfo_info.filename)
    assert_equal({},geneinfo_info.index)
  end

  def test_create_index()
    geneinfo_info = GeneInfo.new("test/data/test_geneinfo.txt")
    geneinfo_info.create_index
    assert_equal(geneinfo_info.index[["chr1",7079000,"GENE.7.0"]],1275)
    assert_raise RuntimeError do
      geneinfo_info.create_index
    end
  end

  def test_transcript()
    geneinfo_info = GeneInfo.new("test/data/test_geneinfo.txt")
    geneinfo_info.create_index
    transcript = geneinfo_info.transcript("chr1",23373262,"GENE.47.0")
    #chr1  - 23373262  23390014  4 23373262,23382568,23385810,23389653,  23377287,23382714,23385897,23390014,  GENE.47.0
    assert_equal(transcript,[23373262,23377287,23382568,23382714,23385810,23385897,23389653,23390014])
  end

end