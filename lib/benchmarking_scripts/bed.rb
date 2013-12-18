class Bed < FileFormats

  def initialize(filename)
    super(filename)
    @false_negatives = {}
    @number_of_spliceforms = Hash.new()
    @coverage = Hash.new()
  end

  attr_accessor :false_negatives, :number_of_spliceforms, :coverage

  def create_index()
    raise "#{@filename} is already indexed" unless @index == {}
    logger.info("Creating index for #{@filename}")
    previous_position = 0
    @filehandle.rewind
    @filehandle.each do |line|
      line.chomp!
      fields = line.split("\t")
      id = fields[3]
      @index[[fields[0],fields[1].to_i,id]] = previous_position if ($EXCLUDE_GENES.select {|e| id.match(e)}).empty?
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
    ende = fields[2].to_i
    raise "Endposition (#{ende}) does not match calculated end position (#{transcript[-1]})" unless ende == transcript[-1]
    transcript.sort!
  end

  def find_number_of_spliceforms()
    logger.info("Searching for number of spliceforms for #{@filename}")
    last_chr = ""
    last_highest = 0
    current_number_of_spliceforms = 0
    current_transcripts = []
    @filehandle.rewind
    @filehandle.each do |line|
      line.chomp!
      fields = line.split("\t")
      id = fields[3]
      key = [fields[0],fields[1].to_i,id]
      trans = transcript(key)
      logger.debug("#{fields[0]}\t#{last_chr}\t#{trans[0]}\t#{last_highest}")
      if fields[0] != last_chr || trans[0] > last_highest
        logger.debug("YES")
        if current_number_of_spliceforms >= 1
          current_transcripts.each do |key2|
            @number_of_spliceforms[key2] = current_number_of_spliceforms
          end
        end
        current_number_of_spliceforms = 0
        current_transcripts = []
        last_highest = trans[-1]
        last_chr = fields[0]
      end
      current_transcripts << key
      current_number_of_spliceforms += 1
    end
    if current_number_of_spliceforms >= 1
      current_transcripts.each do |key2|
        @number_of_spliceforms[key2] = current_number_of_spliceforms
      end
    end
    logger.debug(@number_of_spliceforms)
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
      fpkm_value_out = fields[4]
      break
    end
    #logger.info("fpkm_value is #{fpkm_value_out} for key #{key}")
    fpkm_value_out.to_f
  end

  def determine_false_negatives()
    @false_negatives = @index.dup
  end

end