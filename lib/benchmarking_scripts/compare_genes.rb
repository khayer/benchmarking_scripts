class CompareGenes
  def initialize()
    # Field 0 is total stats
    @strong_TP = Array.new(11,0)
    @weak_TP = Array.new(11,0)
    @all_FP = Array.new(11,0)
    @false_negatives = Array.new(11,0)
    @compare_transcripts = Hash.new
    @compare_transcripts_old = Hash.new
    @truth_transcripts = Hash.new
    @false_positves_one_exon = 0
  end

  attr_accessor :compare_file, :truth_genefile, :strong_TP, :weak_TP, :all_FP,
    :false_negatives, :false_positves_one_exon

  def in_truth_transcripts(key)
    in_truth_transcript = false
    match_keys = @truth_transcripts.keys.keep_if {|e| e[0] == key[0] && e[1] <= key[1]}
    match_keys.each do |match_key|
      trans = @truth_transcripts[match_key]
      in_truth_transcript = true if key[1] >= trans[0] && key[1] <= trans[-1]
      break if in_truth_transcript
    end
    in_truth_transcript
  end

  # Statistics for strong true positives
  def statistics()
    @truth_genefile.index.each_key do |key|
      @truth_transcripts[key] = @truth_genefile.transcript(key)
    end
    logger.debug("Truth Transcripts: #{@truth_transcripts}")
    @compare_file.index.each_key do |key|
      @compare_transcripts_old[key] = @compare_file.transcript(key)
      if in_truth_transcripts(key)
        @compare_transcripts[key] = @compare_file.transcript(key)
        logger.debug(key)
      end
    end
    logger.debug("Compare Transcripts: #{@compare_transcripts}")
    logger.info("Statistics for strong true positives started!")
    statistics_strong
    logger.info("Statistics for weak true positives started!")
    @truth_transcripts.each_pair do |key, value|
      inner_trans = value[1..-2]
      if inner_trans.length >= 2
        @truth_transcripts[key] = inner_trans
      else
        @truth_transcripts.delete(key)
      end
    end
    @compare_transcripts.each_pair do |key, value|
      inner_trans = value[1..-2]
      if inner_trans.length >= 2
        @compare_transcripts[key] = inner_trans
      else
        @compare_transcripts.delete(key)
        @false_positves_one_exon += 1
      end
    end
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
    puts "False positives one exon:\t#{@false_positves_one_exon}"
    puts "(Total number of reported transcripts:\t#{@compare_transcripts_old.length})"
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
    @truth_transcripts.each_pair do |key, value|
      if @compare_transcripts.has_value?(value)
        @strong_TP[0] += 1
        @weak_TP[0] += 1
        if @truth_genefile.kind_of?(GeneInfo)
          number_of_spliceforms = (key[2].split(".")[1].to_f / 1000).ceil
          @strong_TP[number_of_spliceforms] = 0 unless @strong_TP[number_of_spliceforms]
          @strong_TP[number_of_spliceforms] += 1
          @weak_TP[number_of_spliceforms] = 0 unless @weak_TP[number_of_spliceforms]
          @weak_TP[number_of_spliceforms] += 1
        end
        if @truth_genefile.kind_of?(Bed)
          number_of_spliceforms = @truth_genefile.number_of_spliceforms[key]
          @strong_TP[number_of_spliceforms] = 0 unless @strong_TP[number_of_spliceforms]
          @strong_TP[number_of_spliceforms] += 1
          @weak_TP[number_of_spliceforms] = 0 unless @weak_TP[number_of_spliceforms]
          @weak_TP[number_of_spliceforms] += 1
        end
        if @truth_genefile.kind_of?(FeatureQuantifications)
          number_of_spliceforms = @truth_genefile.number_of_spliceforms[key]
          @strong_TP[number_of_spliceforms] = 0 unless @strong_TP[number_of_spliceforms]
          @strong_TP[number_of_spliceforms] += 1
          @weak_TP[number_of_spliceforms] = 0 unless @weak_TP[number_of_spliceforms]
          @weak_TP[number_of_spliceforms] += 1
          coverage = Math.log(@truth_genefile.coverage[key]+1)
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
        compare_key = @compare_transcripts.key(value)
        @compare_transcripts.delete(compare_key)
        @truth_transcripts.delete(key)
        @truth_genefile.false_negatives.delete(key)
      end
    end
  end

  def statistics_weak()
    @truth_transcripts.each_pair do |key, value|
      if @compare_transcripts.has_value?(value)
        @weak_TP[0] += 1
        if @truth_genefile.kind_of?(GeneInfo)
          number_of_spliceforms = (key[2].split(".")[1].to_f / 1000).ceil
          @weak_TP[number_of_spliceforms] = 0 unless @weak_TP[number_of_spliceforms]
          @weak_TP[number_of_spliceforms] += 1
        end
        if @truth_genefile.kind_of?(Bed)
          number_of_spliceforms = @truth_genefile.number_of_spliceforms[key]
          @weak_TP[number_of_spliceforms] = 0 unless @weak_TP[number_of_spliceforms]
          @weak_TP[number_of_spliceforms] += 1
        end
        if @truth_genefile.kind_of?(FeatureQuantifications)
          number_of_spliceforms = @truth_genefile.number_of_spliceforms[key]
          @weak_TP[number_of_spliceforms] = 0 unless @weak_TP[number_of_spliceforms]
          @weak_TP[number_of_spliceforms] += 1
          coverage = Math.log(@truth_genefile.coverage[key]+1)
          coverage = 0 if coverage < 0
          coverage = coverage.floor
          while coverage >= 0
            @weak_TP_by_cov[coverage] = 0 unless @weak_TP_by_cov[coverage]
            @weak_TP_by_cov[coverage] += 1
            coverage -= 1
          end
        end
        compare_key = @compare_transcripts.key(value)
        @compare_transcripts.delete(compare_key)
        @truth_transcripts.delete(key)
        @truth_genefile.false_negatives.delete(key)
      end
    end
  end

  def statistics_fp()
    @compare_transcripts.each_pair do |compare_key, value|
      @truth_genefile.index.each_key do |key|
        if key[0] == compare_key[0] && is_within?(key[1],compare_key[1])
          #puts "NOW" if key[2] = "GENE.217.0"
          @all_FP[0] += 1
          if @truth_genefile.kind_of?(GeneInfo)
            number_of_spliceforms = (key[2].split(".")[1].to_f / 1000).ceil
            @all_FP[number_of_spliceforms] = 0 unless @all_FP[number_of_spliceforms]
            @all_FP[number_of_spliceforms] += 1
          end
          if @truth_genefile.kind_of?(Bed)
            number_of_spliceforms = @truth_genefile.number_of_spliceforms[key]
            @all_FP[number_of_spliceforms] = 0 unless @all_FP[number_of_spliceforms]
            @all_FP[number_of_spliceforms] += 1
          end
          if @truth_genefile.kind_of?(FeatureQuantifications)
            number_of_spliceforms = @truth_genefile.number_of_spliceforms[key]
            @all_FP[number_of_spliceforms] = 0 unless @all_FP[number_of_spliceforms]
            @all_FP[number_of_spliceforms] += 1
            coverage = Math.log(@truth_genefile.coverage[key]+1)
            coverage = 0 if coverage < 0
            coverage = coverage.floor
            while coverage >= 0
              @all_FP_by_cov[coverage] = 0 unless @all_FP_by_cov[coverage]
              @all_FP_by_cov[coverage] += 1
              coverage -= 1
            end
          end
          @compare_transcripts.delete(compare_key)
          @truth_transcripts.delete(key)
          break
        end
      end
    end
    @all_FP[0] += @compare_transcripts.length
    nil
  end

  def statistics_fn()
    @truth_genefile.false_negatives.each_pair do |key,value|
      @false_negatives[0] += 1
      if @truth_genefile.kind_of?(GeneInfo)
        number_of_spliceforms = (key[2].split(".")[1].to_f / 1000).ceil
        @false_negatives[number_of_spliceforms] = 0 unless @false_negatives[number_of_spliceforms]
        @false_negatives[number_of_spliceforms] += 1
      end
      if @truth_genefile.kind_of?(Bed)
        number_of_spliceforms = @truth_genefile.number_of_spliceforms[key]
        @false_negatives[number_of_spliceforms] = 0 unless @false_negatives[number_of_spliceforms]
        @false_negatives[number_of_spliceforms] += 1
      end
      if @truth_genefile.kind_of?(FeatureQuantifications)
        number_of_spliceforms = @truth_genefile.number_of_spliceforms[key]
        @false_negatives[number_of_spliceforms] = 0 unless @false_negatives[number_of_spliceforms]
        @false_negatives[number_of_spliceforms] += 1
        coverage = Math.log(@truth_genefile.coverage[key]+1)
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