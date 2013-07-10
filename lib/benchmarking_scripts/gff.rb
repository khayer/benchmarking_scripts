class GFF < FileFormats

  def create_index()
    raise "#{@filename} is already indexed" unless @index == {}
    logger.info("Creating index for #{@filename}")
    last_position = 0
    id = "unknown"
    fields = []
    @filehandle.rewind
    @filehandle.each do |line|
      line.chomp!
      if line =~ /gene/
        fields = line.split(" ")
        id = fields[-1].split("=")[1].split(";")[0]
        last_position = @filehandle.pos
      end
      if line =~ /mRNA/
        coverage = line.split("coverage=")[1].split(";")[0].to_f
        identity = line.split("identity=")[1].split(";")[0].to_f
        @index[[fields[0],fields[3].to_i-1,id]] = last_position if identity >= 95.0 && coverage >= 95.0
      end
    end
    logger.info("Indexing of #{@index.length} transcripts complete")
  end

  def transcript(key)
    transcript = []
    pos_in_file = @index[key]
    @filehandle.pos = pos_in_file
    @filehandle.each do |line|
      break if line =~ /###/ or line =~ /CDS/
      next if line =~ /mRNA/
      line.chomp!
      fields = line.split(" ")
      transcript << fields[3].to_i-1
      transcript << fields[4].to_i
    end
    transcript.sort!
  end

end