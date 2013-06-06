class CompareGenes
  def initialize()
    # Field 0 is total stats
    @strong_TP = Array.new(11,0)
    @weak_TP = Array.new(11,0)
    @all_FP = Array.new(11,0)
  end

  attr_accessor :compare_file, :truth_genefile, :strong_TP, :weak_TP, :all_FP

  # Statistics for strong true positives
  def statistics()
    logger.info("Statistics for strong true positives started!")
    statistics_strong
    logger.info("Statistics for weak true positives started!")
    statistics_weak
    logger.info("Statistics for false positives started!")
    statistics_fp
  end

  private
  def statistics_strong()
    @compare_file.index.each_key do |info|
      @truth_genefile.index.each_key do |key|
        if key[0] == info[0] && key[1] == info[1]
          truth_genefile_transcript= @truth_genefile.transcript(key[0],key[1],key[2])
          gff_transcript = @compare_file.transcript(info[0],info[1],info[2])
          if truth_genefile_transcript == gff_transcript
            @strong_TP[0] += 1
            @weak_TP[0] += 1
            number_of_spliceforms = (key[2].split(".")[1].to_f / 1000).ceil
            @strong_TP[number_of_spliceforms] += 1
            @weak_TP[number_of_spliceforms] += 1
            @compare_file.index.delete(info)
            break
          end
        end
      end
    end
  end

  def statistics_weak()
    @compare_file.index.each_key do |info|
      @truth_genefile.index.each_key do |key|
        if key[0] == info[0] && is_within?(key[1],info[1])
          truth_genefile_transcript= @truth_genefile.transcript(key[0],key[1],key[2])
          gff_transcript = @compare_file.transcript(info[0],info[1],info[2])
          truth_genefile_transcript = truth_genefile_transcript[1..-2]
          gff_transcript = gff_transcript[1..-2]
          if truth_genefile_transcript == gff_transcript
            @weak_TP[0] += 1
            number_of_spliceforms = (key[2].split(".")[1].to_f / 1000).ceil
            @weak_TP[number_of_spliceforms] += 1
            @compare_file.index.delete(info)
            break
          end
        end
      end
    end
  end

  def statistics_fp()
    @compare_file.index.each_key do |info|
      @truth_genefile.index.each_key do |key|
        if key[0] == info[0] && is_within?(key[1],info[1])
          truth_genefile_transcript= @truth_genefile.transcript(key[0],key[1],key[2])
          @all_FP[0] += 1
          number_of_spliceforms = (key[2].split(".")[1].to_f / 1000).ceil
          @all_FP[number_of_spliceforms] += 1
          @compare_file.index.delete(info)
          break
        end
      end
    end
    @all_FP[0] += @compare_file.index.length
    nil
  end
end