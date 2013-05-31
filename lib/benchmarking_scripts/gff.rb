class GFF

  def initialize(filename)
    @filename = filename
    @index = Hash.new()
  end

  attr_accessor :filename, :index

  def create_index()
    raise "#{@filename} is already indexed" unless @index == {}
    logger.info("Creating index for #{@filename}")
    k = File.open(@filename)
    k.each do |line|
      line.chomp!
      next unless line =~ /gene/
      fields = line.split(" ")
      id = fields[-1].split("=")[1].split(";")[0]
      @index[[fields[0],fields[3].to_i-1,id]] = k.pos
    end
    logger.warn("Indexing of #{@index.length} transcripts complete")
    k.close
  end

  def transcript(chr,pos,id)
    transcript = []
    pos_in_file = @index[[chr,pos,id]]
    k = File.open(@filename)
    k.pos = pos_in_file
    k.each do |line|
      break if line =~ /###/ or line =~ /CDS/
      next if line =~ /mRNA/
      line.chomp!
      fields = line.split(" ")
      transcript << fields[3].to_i-1
      transcript << fields[4].to_i
    end
    k.close
    transcript.sort!
  end

end