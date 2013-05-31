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
    last_position = 0
    id = "unknown"
    fields = []
    k.each do |line|
      line.chomp!
      if line =~ /gene/
        fields = line.split(" ")
        id = fields[-1].split("=")[1].split(";")[0]
        last_position = k.pos
      end
      if line =~ /mRNA/
        coverage = line.split("coverage=")[1].split(";")[0].to_f
        identity = line.split("identity=")[1].split(";")[0].to_f
        @index[[fields[0],fields[3].to_i-1,id]] = last_position if identity >= 95.0 && coverage >= 95.0
      end
    end
    logger.info("Indexing of #{@index.length} transcripts complete")
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