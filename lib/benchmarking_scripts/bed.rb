class Bed < FileFormats

  def initialize(filename)
    super(filename)
  end

  attr_accessor

  def create_index()
    raise "#{@filename} is already indexed" unless @index == {}
    logger.info("Creating index for #{@filename}")
    previous_position = 0
    @filehandle.rewind
    @filehandle.each do |line|
      line.chomp!
      fields = line.split("\t")
      id = fields[3]
      @index[[fields[0],fields[1].to_i,id]] = previous_position
      previous_position = @filehandle.pos
    end
    logger.info("Indexing of #{@index.length} transcripts complete")
  end

  def transcript(key)
    transcript = []
    pos_in_file = @index[key]
    @filehandle.pos = pos_in_file
    line = @filehandle.readline
    fields = line.split("\t")
    lengths = fields[10].split(",")
    offset = fields[11].split(",")
    start = fields[1].to_i
    lengths.each_with_index do |current_length, i|
      current_start = start + offset[i].to_i
      transcript << current_start
      transcript << current_start + current_length.to_i
    end
    ende = fields[7].to_i
    raise "Endposition (#{ende}) does not match calculated end position (#{transcript[-1]})" unless ende == transcript[-1]
    transcript.sort!
  end

  def calculate_coverage()
    @index.each_pair do |key,value|
      @coverage[key] = fpkm_value(key)
    end
  end

  def determine_false_negatives()
    @false_negatives = @index.dup
  end

end