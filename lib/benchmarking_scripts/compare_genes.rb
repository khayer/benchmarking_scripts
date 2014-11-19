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
    @all_TN = Array.new(11,0)
    @all_MCC = Array.new(11,0)
    @all_FDR = Array.new(11,0)
    @all_FNR = Array.new(11,0)
  end

  attr_accessor :compare_file, :truth_genefile, :strong_TP, :weak_TP, :all_FP,
    :false_negatives, :false_positves_one_exon, :all_TN, :all_MCC

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
    logger.info("#{@already_counted}")
    logger.info("#{@false_positives_per_gene}")
    logger.info("Statistics for false negatives started!")

    statistics_fn

    estimate_true_negatives()
    calculate_MCC()
    calculate_FDR()
    calculate_FNR()

  end

  def print_result()
    puts (["#splice_forms"] + (0..10).to_a).join("\t")
    puts "---------------------------------------------------------------------------------------------------------"
    puts (["#Strong TP"] + @strong_TP).join("\t")
    puts (["# Weak TP"] + @weak_TP).join("\t")
    puts (["# All FP"] + @all_FP).join("\t")
    puts (["# All FN"] + @false_negatives).join("\t")
    puts (["# All TN"] + @all_TN).join("\t")
    puts (["# All MCC"] + @all_MCC).join("\t")
    puts (["# All FDR"] + @all_FDR).join("\t")
    puts (["# All FNR"] + @all_FNR).join("\t")
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
    if @truth_genefile.kind_of?(GeneInfo)
      puts ""
      puts (["false_positives_per_gene"] + @false_positives_per_gene).join("\t")
    end
  end

  private
  def in_region(already_counted, value2)
    within = false
    return within if already_counted.empty?
    already_counted.each do |el|
      next unless el[0] == value2[0]
      if el[1] <= value2[1] && el[2] >= value2[1]
        within = true
      end
      if el[1] >= value2[1] && el[1] <= value2[-1]
        within = true
      end
    end
    within
  end


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
            unless in_region(@already_counted, [key[0],value[0],value[-1]])
              @false_positives_per_gene[number_of_spliceforms] = 0 unless  @false_positives_per_gene[number_of_spliceforms]
              @false_positives_per_gene[number_of_spliceforms] += 1
              @already_counted << [key[0],value[0],value[-1]]
            end
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

  def estimate_true_negatives()
    @weak_TP.each_with_index do |tp,i|
      @all_TN[i] = FIXNUM_MAX
    end
  end

  def calculate_MCC()
    @weak_TP.each_with_index do |tp,i|
      tp ||= 0
      tn = @all_TN[i]
      tn ||= 0
      fp = @all_FP[i]
      fp ||= 0
      fn = @false_negatives[i]
      @all_MCC[i] = mcc(tp,tn,fp,fn)
    end
  end

  def calculate_FNR()
    @weak_TP.each_with_index do |tp,i|
      fn = @false_negatives[i]
      fn ||= 0
      @all_FNR[i] = fnr(fn,tp)
    end
  end

  def calculate_FDR()
    @weak_TP.each_with_index do |tp,i|
      fp = @all_FP[i]
      fp ||= 0
      @all_FDR[i] = fdr(fp,tp)
    end
  end

end