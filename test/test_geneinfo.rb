require "./geneinfo.rb"
require "test/unit"

class TestGeneInfo < Test::Unit::TestCase

  def test_initialize
    gff_file = GeneInfo.new("test/data/test_geneinfo.txt")
    assert_equal("test/data/test_geneinfo.txt",gff_file.filename)
    assert_equal({},gff_file.index)
  end

  def test_create_index()
    gff_file = GFF.new("test/data/test_geneinfo.txt")
    gff_file.create_index
    assert_equal(gff_file.index[["chr7",148033816,"scaffold1.path1"]],80)
    assert_raise RuntimeError do
      gff_file.create_index
    end
  end

  def test_transcript()
    gff_file = GFF.new("test/data/test_geneinfo.txt")
    gff_file.create_index
    transcript = gff_file.transcript("chr5",136656235,"scaffold15.path1")
    assert_equal(transcript,[136656235,136657366,136665422,136665489,136667770,136667855,136670167,136670267,136674645,136674818])
  end

end