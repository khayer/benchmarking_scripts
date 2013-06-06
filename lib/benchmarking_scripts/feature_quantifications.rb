class FeatureQuantifications < FileFormats

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
        pos_chr = fields[1].split(":")[1].split("-")[0].to_i
        @index[[chr,pos_chr,last_gene]] = [last_position,fields[-1].to_i]
      end
    #  if line =~ /mRNA/
    #    coverage = line.split("coverage=")[1].split(";")[0].to_f
    #    identity = line.split("identity=")[1].split(";")[0].to_f
    #    @index[[fields[0],fields[3].to_i-1,id]] = last_position if identity >= 95.0 && coverage >= 95.0
    #  end
    end
    #logger.info("Indexing of #{@index.length} transcripts complete")
    k.close
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
      transcript << line.split("-")[0].split(":")[1].to_i
      transcript << line.split("-")[1].split(" ")[0].to_i
    end
    k.close
    transcript.sort!
  end

  def frag_count(chr,pos,id)
    value = @index[[chr,pos,id]]
    frag_counts = value[1]
  end

  def fpkm_for_transcript(transcript,fragment,mio_reads=50)
    trans_length = calc_length(transcript)
    fpkm(fragment,trans_length)
  end

end