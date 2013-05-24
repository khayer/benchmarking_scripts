require "./gff.rb"
require "test/unit"

class TestGFF < Test::Unit::TestCase

  def test_initialize
    gff_file = GFF.new("test/data/test.gff")
    assert_equal("test/data/test.gff",gff_file.filename)
    assert_equal({},gff_file.index)
  end

  def test_create_index()
    gff_file = GFF.new("test/data/test.gff")
    gff_file.create_index
    assert_equal(gff_file.index[["chr7",148033816]],39855)
  end

end