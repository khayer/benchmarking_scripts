class GTF < FileFormats

  def initialize(filename)
    super(filename)
    @coverage = Hash.new()
  end

  attr_accessor :coverage

  def create_index()
    raise "#{@filename} is already indexed" unless @index == {}
    logger.info("Creating index for #{@filename}")
    @filehandle.rewind
    @filehandle.each do |line|
      line.chomp!
      next if line =~ /cov "0.000000"/
      next unless line =~ /\stranscript\s/
      fields = line.split("\t")
      id = fields[-1].split("transcript_id ")[1].split(";")[0]
      @index[[fields[0],fields[3].to_i-1,id]] = @filehandle.pos
    end
    logger.info("Indexing of #{@index.length} transcripts complete")
  end

  def transcript(key)
    transcript = []
    pos_in_file = @index[key]
    @filehandle.pos = pos_in_file
    @filehandle.each do |line|
      break if line =~ /\stranscript\s/
      #next if line =~ /mRNA/
      line.chomp!
      fields = line.split(" ")
      transcript << fields[3].to_i-1
      transcript << fields[4].to_i
    end
    transcript.sort!
  end

  def calculate_coverage()
    @index.each_pair do |key,value|
      @coverage[key] = fpkm_value(key)
    end
  end

  def fpkm_value(key)
    pos_in_file = @index[key]
    @filehandle.pos = pos_in_file
    fpkm_value_out = 0
    @filehandle.each do |line|
      fields = line.split("\t")
      fpkm_value_out = fields[-1].split("FPKM ")[1].split(";")[0].delete("\"")
      break
    end
    #logger.info("fpkm_value is #{fpkm_value_out} for key #{key}")
    fpkm_value_out.to_f
  end

end