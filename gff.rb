class GFF

  def initialize(filename)
    @filename = filename
    @index = Hash.new()
  end

  attr_accessor :filename, :index

  def create_index()
    raise "#{@filename} is already indexed" unless @index == {}
    k = File.open(@filename)

    k.each do |line|
      line.chomp!
      next unless line =~ /gene/
      puts k.pos
    end
  end

  def multiply(y)
    @x * y
  end

end