require "./gff.rb"
require "test/unit"

class TestGFF < Test::Unit::TestCase

  def test_initialize
    gff_file = GFF.new("data/test.gff")
    assert_equal("data/test.gff",gff_file.filename)
    assert_equal({},gff_file.index)
  end

end