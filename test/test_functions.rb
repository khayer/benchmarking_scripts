require "./test/test_helper"

class TestFunctions < Test::Unit::TestCase

  def test_fpkm
    assert_equal(fpkm(1659,2687),12.348343877930779)
  end

  def test_calc_length()
    transcript = [136656234,136657366,136665421,136665489,136667769,136667855,136670166,136670267,136674644,136674818]
    assert_equal(calc_length(transcript),1561)
    transcript = [127573573,127574769,127768947,127770438]
    assert_equal(calc_length(transcript),2687)
  end

  def test_xyz()

  end

end