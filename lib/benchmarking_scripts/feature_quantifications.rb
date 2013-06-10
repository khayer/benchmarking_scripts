class FeatureQuantifications < FileFormats

  def initialize(filename)
    super(filename)
    @number_of_spliceforms = Hash.new()
    @coverage = Hash.new()
    @m = 0
    @false_negatives = Hash.new()
  end

  attr_accessor :number_of_spliceforms, :coverage, :m, :false_negatives

  def create_index()
    raise "#{@filename} is already indexed" unless @index == {}
    logger.info("Creating index for #{@filename}")
    k = File.open(@filename)
    last_gene = "unknown"
    last_position = 0
    k.each do |line|
      line.chomp!
      if line =~ /GENE/
        last_gene = line.split("\t")[0]
        last_position = k.pos
      end
      if line =~ /transcript/
        fields = line.split("\t")
        chr = fields[1].split(":")[0]
        pos_chr = fields[1].split(":")[1].split("-")[0].to_i-1
        @index[[chr,pos_chr,last_gene]] = [last_position,fields[-1].to_i]
      end
    end
    logger.info("Indexing of #{@index.length} transcripts complete")
    k.close
  end

  def find_number_of_spliceforms()
    logger.info("Searching for number of spliceforms for #{@filename}")
    k = File.open(@filename)
    last_gene = "unknown"
    last_chr = ""
    last_highest_end = 0
    last_highest = 0
    last_position = 0
    current_number_of_spliceforms = 0
    current_transcripts = []
    k.each do |line|
      line.chomp!
      if line =~ /GENE/
        last_gene = line.split("\t")[0]
        last_position = k.pos
      end
      if line =~ /transcript/
        fields = line.split("\t")
        chr = fields[1].split(":")[0]
        pos_chr = fields[1].split(":")[1].split("-")[0].to_i-1
        pos_chr_end = fields[1].split("-")[1].split("\t")[0].to_i
        current_transcripts << [chr,pos_chr,last_gene]
        current_number_of_spliceforms += 1
        if pos_chr_end > last_highest_end
          last_highest_end = pos_chr_end
        end
        if pos_chr > last_highest || chr != last_chr
          dummy = current_transcripts.delete_at(-1)
          current_transcripts.each do |transcript|
            @number_of_spliceforms[transcript] = current_number_of_spliceforms
          end
          current_transcripts = [dummy]
          current_number_of_spliceforms = 0
          last_chr = chr
          last_highest = last_highest_end
        end
      end
      current_transcripts.each do |transcript|
        @number_of_spliceforms[transcript] = current_number_of_spliceforms+1
      end
    end
    k.close
  end

  def calculate_coverage(mio_reads=@m)
    @index.each_pair do |key,value|
      @coverage[key] = fpkm_value(transcript(key[0],key[1],key[2]),value[1],mio_reads)
    end
  end

  def transcript(chr,pos,id)
    transcript = []
    value = @index[[chr,pos,id]]
    pos_in_file = value[0]
    k = File.open(@filename)
    k.pos = pos_in_file
    k.each do |line|
      break if line =~ /GENE/
      next unless line =~ /exon/
      line.chomp!
      transcript << line.split("-")[0].split(":")[1].to_i-1
      transcript << line.split("-")[1].split(" ")[0].to_i
    end
    k.close
    transcript.sort!
  end

  def calculate_M()
    raise "M was already definied!" unless @m == 0
    logger.info("Calculating M for #{@filename}")
    k = File.open(@filename)
    k.each do |line|
      line.chomp!
      if line =~ /transcript/
        fields = line.split("\t")
        @m += fields[-1].to_i
      end
    end
    k.close
    @m = @m/1000000
    logger.info("M is #{@m}")
  end

  def determine_false_negatives(cutoff=500)
    fn = @coverage.values.sort.reverse[0..cutoff]
    @coverage.each_pair do |key,value|
      @false_negatives[key] = value if fn.include?(value)
    end
  end

  def frag_count(chr,pos,id)
    value = @index[[chr,pos,id]]
    frag_counts = value[1]
  end

  def fpkm_value(transcript,fragment,mio_reads=@m)
    trans_length = calc_length(transcript)
    raise "M needs to be definied!" if mio_reads == 0
    fpkm(fragment,trans_length,mio_reads)
  end

end