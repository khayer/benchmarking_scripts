class FileFormats
  def initialize(filename)
    @filename = filename
    @index = Hash.new()
    @filehandle = File.open(@filename)
  end

  attr_accessor :filename, :index

  def create_index()
  end

  def reopen()
    @filehandle = File.open(@filename)
  end

  def close()
    @filehandle.close()
    @filehandle = nil
    if @logger 
      @logger =nil
    end
  end  

  def transcript(chr,pos,id)
  end

end