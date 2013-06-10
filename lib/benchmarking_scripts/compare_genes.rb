class CompareGenes
  def initialize()
    # Field 0 is total stats
    @strong_TP = Array.new(11,0)
    @weak_TP = Array.new(11,0)
    @all_FP = Array.new(11,0)
    @false_negatives = Array.new(11,0)
  end

  attr_accessor :compare_file, :truth_genefile, :strong_TP, :weak_TP, :all_FP, :false_negatives

  # Statistics for strong true positives
  def statistics()
    logger.info("Statistics for strong true positives started!")
    statistics_strong
    logger.info("Statistics for weak true positives started!")
    statistics_weak
    logger.info("Statistics for false positives started!")
    statistics_fp
    logger.info("Statistics for false negatives started!")
    statistics_fn
  end

  def print_result()
    puts (["#splice_forms"] + (0..10).to_a).join("\t")
    puts "---------------------------------------------------------------------------------------------------------"
    puts (["#Strong TP"] + @strong_TP).join("\t")
    puts (["# Weak TP"] + @weak_TP).join("\t")
    puts (["# All FP"] + @all_FP).join("\t")
    puts (["# All FN"] + @false_negatives).join("\t")
    if @truth_genefile.kind_of?(FeatureQuantifications)
      puts ""
      puts (["log(coverage)"] + (0..10).to_a).join("\t")
      puts "---------------------------------------------------------------------------------------------------------"
      puts (["#Strong TP"] + @strong_TP_by_cov).join("\t")
      puts (["# Weak TP"] + @weak_TP_by_cov).join("\t")
      puts (["# All FP"] + @all_FP_by_cov).join("\t")
      puts (["# All FN"] + @false_negatives_by_cov).join("\t")
    end
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
            if @truth_genefile.kind_of?(GeneInfo)
              number_of_spliceforms = (key[2].split(".")[1].to_f / 1000).ceil
              @strong_TP[number_of_spliceforms] += 1
              @weak_TP[number_of_spliceforms] += 1
            end
            if @truth_genefile.kind_of?(FeatureQuantifications)
              number_of_spliceforms = @truth_genefile.number_of_spliceforms[[key[0],key[1],key[2]]]
              @strong_TP[number_of_spliceforms] += 1
              @weak_TP[number_of_spliceforms] += 1
              coverage = Math.log(@truth_genefile.coverage[key])
              coverage = 0 if coverage < 0
              coverage = coverage.floor
              while coverage >= 0
                @strong_TP_by_cov[coverage] = 0 unless @strong_TP_by_cov[coverage]
                @strong_TP_by_cov[coverage] += 1
                @weak_TP_by_cov[coverage] = 0 unless @weak_TP_by_cov[coverage]
                @weak_TP_by_cov[coverage] += 1
                coverage -= 1
              end
            end
            @compare_file.index.delete(info)
            @truth_genefile.false_negatives.delete(key)
            break
          end
        end
      end
    end
  end

  def statistics_weak()
    logger.debug("Index is now #{@compare_file.index.length()}")
    @compare_file.index.each_key do |info|
      @truth_genefile.index.each_key do |key|
        if key[0] == info[0] && is_within?(key[1],info[1])
          truth_genefile_transcript= @truth_genefile.transcript(key[0],key[1],key[2])
          gff_transcript = @compare_file.transcript(info[0],info[1],info[2])
          truth_genefile_transcript = truth_genefile_transcript[1..-2]
          gff_transcript = gff_transcript[1..-2]
          next if truth_genefile_transcript == []
          if truth_genefile_transcript == gff_transcript
            @weak_TP[0] += 1
            if @truth_genefile.kind_of?(GeneInfo)
              number_of_spliceforms = (key[2].split(".")[1].to_f / 1000).ceil
              @weak_TP[number_of_spliceforms] += 1
            end
            if @truth_genefile.kind_of?(FeatureQuantifications)
              number_of_spliceforms = @truth_genefile.number_of_spliceforms[key]
              @weak_TP[number_of_spliceforms] += 1
              coverage = Math.log(@truth_genefile.coverage[key])
              coverage = 0 if coverage < 0
              coverage = coverage.floor
              while coverage >= 0
                @weak_TP_by_cov[coverage] = 0 unless @weak_TP_by_cov[coverage]
                @weak_TP_by_cov[coverage] += 1
                coverage -= 1
              end
            end
            @compare_file.index.delete(info)
            @truth_genefile.false_negatives.delete(key)
            break
          end
        end
      end
    end
  end

  def statistics_fp()
    logger.debug("Index is now #{@compare_file.index.length()}")
    @compare_file.index.each_key do |info|
      @truth_genefile.index.each_key do |key|

        if key[0] == info[0] && is_within?(key[1],info[1])
          #puts "NOW" if key[2] = "GENE.217.0"
          @all_FP[0] += 1
          if @truth_genefile.kind_of?(GeneInfo)
            number_of_spliceforms = (key[2].split(".")[1].to_f / 1000).ceil
            @all_FP[number_of_spliceforms] += 1
          end
          if @truth_genefile.kind_of?(FeatureQuantifications)
            number_of_spliceforms = @truth_genefile.number_of_spliceforms[[key[0],key[1],key[2]]]
            @all_FP[number_of_spliceforms] += 1
            coverage = Math.log(@truth_genefile.coverage[key])
            coverage = 0 if coverage < 0
            coverage = coverage.floor
            while coverage >= 0
              @all_FP_by_cov[coverage] = 0 unless @all_FP_by_cov[coverage]
              @all_FP_by_cov[coverage] += 1
              coverage -= 1
            end
          end
          @compare_file.index.delete(info)
          break
        end
      end
    end
    @all_FP[0] += @compare_file.index.length
    nil
  end

  def statistics_fn()
    @truth_genefile.false_negatives.each_pair do |key,value|
      @false_negatives[0] += 1
      if @truth_genefile.kind_of?(GeneInfo)
        number_of_spliceforms = (key[2].split(".")[1].to_f / 1000).ceil
        @false_negatives[number_of_spliceforms] += 1
      end
      if @truth_genefile.kind_of?(FeatureQuantifications)
        number_of_spliceforms = @truth_genefile.number_of_spliceforms[[key[0],key[1],key[2]]]
        @false_negatives[number_of_spliceforms] += 1
        coverage = Math.log(@truth_genefile.coverage[key])
        coverage = 0 if coverage < 0
        coverage = coverage.floor
        while coverage >= 0
          @false_negatives_by_cov[coverage] = 0 unless @false_negatives_by_cov[coverage]
          @false_negatives_by_cov[coverage] += 1
          coverage -= 1
        end
      end
    end
  end

end