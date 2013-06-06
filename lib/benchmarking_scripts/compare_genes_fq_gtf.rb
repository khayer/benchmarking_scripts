class CompareGenesFQGTF < CompareGenes

  def initialize(feature_quant_file,gtf_file)
    super()
    @truth_genefile = FeatureQuantifications.new(feature_quant_file)
    @compare_file = GTF.new(gtf_file)
    @fpkm_values = []
  end


  #def statistics_strong()
  #  @compare_file.index.each_key do |info|
  #    @truth_genefile.index.each_key do |key|
  #      if key[0] == info[0] && key[1] == info[1]
  #        truth_genefile_transcript= @truth_genefile.transcript(key[0],key[1],key[2])
  #        gff_transcript = @compare_file.transcript(info[0],info[1],info[2])
  #        if truth_genefile_transcript == gff_transcript
  #          @strong_TP[0] += 1
  #          @weak_TP[0] += 1
  #          #number_of_spliceforms = (key[2].split(".")[1].to_f / 1000).ceil
  #          #@strong_TP[number_of_spliceforms] += 1
  #          #@weak_TP[number_of_spliceforms] += 1
  #          @compare_file.index.delete(info)
  #          break
  #        end
  #      end
  #    end
  #  end
  #end
#
  def statistics_fpkm()
    @compare_file.index.each_key do |info|
      @truth_genefile.index.each_key do |key|
        if key[0] == info[0] && is_within?(key[1],info[1])
          truth_genefile_transcript= @truth_genefile.transcript(key[0],key[1],key[2])
          gff_transcript = @compare_file.transcript(info[0],info[1],info[2])
          truth_genefile_transcript = truth_genefile_transcript[1..-2]
          gff_transcript = gff_transcript[1..-2]
          next if truth_genefile_transcript == []
          if truth_genefile_transcript == gff_transcript
            frag_counts = @truth_genefile.frag_count(key[0],key[1],key[2])
            fpkm1 = @truth_genefile.fpkm_value(truth_genefile_transcript,frag_counts)
            fpkm2 = @compare_file.fpkm_value(info[0],info[1],info[2])
            @fpkm_values << [fpkm1,fpkm2]
            logger.debug("NINA")
            logger.debug(fpkm1)
            logger.debug(fpkm2)
            break
          end
        end
      end
    end
  end
#
  #def statistics_fp()
  #  @compare_file.index.each_key do |info|
  #    @truth_genefile.index.each_key do |key|
  #      if key[0] == info[0] && is_within?(key[1],info[1])
  #        truth_genefile_transcript= @truth_genefile.transcript(key[0],key[1],key[2])
  #        @all_FP[0] += 1
  #        #number_of_spliceforms = (key[2].split(".")[1].to_f / 1000).ceil
  #        #@all_FP[number_of_spliceforms] += 1
  #        @compare_file.index.delete(info)
  #        break
  #      end
  #    end
  #  end
  #  @all_FP[0] += @compare_file.index.length
  #  nil
  #end

end