require "./test/test_helper"

class TestBed < Test::Unit::TestCase

  def test_initialize()
    bed_object = Bed.new("test/data/test.bed")
    assert_equal("test/data/test.bed",bed_object.filename)
    assert_equal({},bed_object.index)
  end

  def test_create_index()
    bed_object = Bed.new("test/data/test.bed")
    bed_object.create_index
    assert_equal(bed_object.index[["chr1",1718193,"BC008991"]],0)
    assert_raise RuntimeError do
      bed_object.create_index
    end
  end

  def test_transcript()
    bed_object = Bed.new("test/data/test.bed")
    bed_object.create_index
    transcript = bed_object.transcript(["chr1",19665272,"BC008095"])
    #chr1  - 23373262  23390014  4 23373262,23382568,23385810,23389653,  23377287,23382714,23385897,23390014,  GENE.47.0
    assert_equal(transcript,[19665272, 19666111, 19670851, 19670928, 19671680, 19671746])
    # chr1  9352983 9429590 BC015711
    transcript = bed_object.transcript(["chr1",9352983,"BC015711"])
    assert_equal(transcript,[9352983, 9353015, 9353021, 9353130, 9415801, 9416644, 9427506, 9429590])
  end

end