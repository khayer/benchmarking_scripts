class Bed < FileFormats

  def initialize(filename)
    super(filename)
  end

  attr_accessor

  def create_index()
    raise "#{@filename} is already indexed" unless @index == {}
    logger.info("Creating index for #{@filename}")
    k = File.open(@filename)
    k.each do |line|
      line.chomp!
      fields = line.split("\t")
      id = fields[3]
      @index[[fields[0],fields[1].to_i,id]] = k.pos
    end
    logger.info("Indexing of #{@index.length} transcripts complete")
    k.close
  end

  def transcript(key)
    transcript = []
    pos_in_file = @index[key]
    k = File.open(@filename)
    k.pos = pos_in_file
    line = k.readline
    fields = line.split("\t")
    lengths = fields[10].split(",")
    offset = fields[11].split(",")
    lengths.each_with_index do |current_length, i|
      current_start = start + offset[i].to_i
      transcript << current_start
      transcript << current_start + current_length.to_i
    end
    k.close
    transcript.sort!
  end

  def calculate_coverage()
    @index.each_pair do |key,value|
      @coverage[key] = fpkm_value(key)
    end
  end

  def fpkm_value(key)
    pos_in_file = @index[key]
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