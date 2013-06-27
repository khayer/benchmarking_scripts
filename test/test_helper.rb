require "test/unit"
require 'benchmarking_scripts'

class TestGTF < Test::Unit::TestCase

  Logging.configure({ "logout" => STDERR, "log_level" => Logger::INFO })

end
