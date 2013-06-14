class GeneInfo < FileFormats

  def initialize(filename)
    super(filename)
    @false_negatives = Hash.new()
  end

  attr_accessor :false_negatives

  def create_index()
    raise "#{@filename} is already indexed" unless @index == {}
    logger.info("Creating index for #{@filename}")
    k = File.open(@filename)
    previous_position = 0
    k.each do |line|
      line.chomp!
      fields = line.split(" ")
      id = fields[-1]
      @index[[fields[0],fields[2].to_i,id]] = previous_position
      previous_position = k.pos
    end
    logger.info("Indexing of #{@index.length} transcripts complete")
    logger.debug(@index)
    k.close
  end

  def transcript(chr,pos,id)
    transcript = []
    pos_in_file = @index[[chr,pos,id]]
    k = File.open(@filename)
    k.pos = pos_in_file
    line = k.readline
    line.chomp!
    fields = line.split(" ")
    fields[5].split(",").each do |num|
      transcript << num.to_i
    end
    fields[6].split(",").each do |num|
      transcript << num.to_i
    end
    k.close
    transcript.sort!
  end

  def determine_false_negatives()
    @false_negatives = @index.dup
  end


end