class HTSeq < FileFormats

  def initialize(filename)
    super(filename)
    @counts = Hash.new()
  end

  attr_accessor :counts

  def create_index()
    raise "#{@filename} is already indexed" unless @index == {}
    logger.info("Creating index for #{@filename}")
    last_position = 0
    id = "unknown"
    fields = []
    @filehandle.each do |line|
      line.chomp!
      next unless line =~ /^GENE/
      name,num = line.split("\t")
      @index[name] = num
    end
    logger.info("Indexing of #{@index.length} transcripts complete")
  end

  def transcript(key)
    transcript = @index[key].to_i
  end

  def calculate_counts()
    @index.each_pair do |key,value|
      @counts[key] = value
    end
  end
end