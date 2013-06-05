class GeneInfo < FileFormats

  def create_index()
    raise "#{@filename} is already indexed" unless @index == {}
    k = File.open(@filename)
    previous_position = 0
    k.each do |line|
      line.chomp!
      fields = line.split(" ")
      id = fields[-1]
      @index[[fields[0],fields[2].to_i,id]] = previous_position
      previous_position = k.pos
    end
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

end