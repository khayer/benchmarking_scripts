class GTF < FileFormats

  def initialize(filename)
    super(filename)
    @coverage = Hash.new()
  end

  attr_accessor :coverage

  def create_index()
    raise "#{@filename} is already indexed" unless @index == {}
    logger.info("Creating index for #{@filename}")
    k = File.open(@filename)
    k.each do |line|
      line.chomp!
      next if line =~ /"0.000000"/
      next unless line =~ /\stranscript\s/
      fields = line.split("\t")
      id = fields[-1].split("transcript_id ")[1].split(";")[0]
      @index[[fields[0],fields[3].to_i-1,id]] = k.pos
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
      break if line =~ /\stranscript\s/
      #next if line =~ /mRNA/
      line.chomp!
      fields = line.split(" ")
      transcript << fields[3].to_i-1
      transcript << fields[4].to_i
    end
    k.close
    transcript.sort!
  end

  def calculate_coverage()
    @index.each_pair do |key,value|
      @coverage[key] = fpkm_value(key[0],key[1],key[2])
    end
  end

  def fpkm_value(chr,pos,id)
    pos_in_file = @index[[chr,pos,id]]
    k = File.open(@filename)
    k.pos = pos_in_file
    fpkm_value_out = 0
    k.each do |line|
      fields = line.split("\t")
      fpkm_value_out = fields[-1].split("FPKM ")[1].split(";")[0].delete("\"")
      break
    end
    fpkm_value_out.to_f
  end

end