class GFF

  def initialize(filename)
    @filename = filename
    @index = Hash.new()
  end

  attr_accessor :filename, :index

  def create_index()
    raise "#{@filename} is already indexed" unless @index == {}
    File.open(@filename).each do |line|

    end
  end

  def multiply(y)
    @x * y
  end

end