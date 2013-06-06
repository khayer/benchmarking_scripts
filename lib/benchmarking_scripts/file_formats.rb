class FileFormats
  def initialize(filename)
    @filename = filename
    @index = Hash.new()
  end

  attr_accessor :filename, :index

  def create_index()
  end

  def transcript(chr,pos,id)
  end

end