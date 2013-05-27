require "./geneinfo.rb"
require "./gff.rb"

class CompareGenes
  def initialize(gff_file,geneinfo_file)
    @gff = GFF.new(gff_file)
    @geneinfo = GeneInfo.new(geneinfo_file)
    # Field 0 is total stats
    @strong_TP = Array.new(11,0)
    @weak_TP = Array.new(11,0)
    @all_FP = Array.new(11,0)
  end

  attr_accessor :gff, :geneinfo, :strong_TP, :weak_TP, :all_FP

  # Statistics for strong true positives
  def statistics()
    statistics_strong
    statistics_weak
    statistics_fp
  end

  private 
  def is_within?(pos1, pos2, boundry=1000000)
    (pos1 - pos2).abs() < boundry
  end

  def statistics_strong()
    @gff.index.each_key do |info|    
      @geneinfo.index.each_key do |key|
        if key[0] == info[0] && key[1] == info[1]
          geneinfo_transcript= @geneinfo.transcript(key[0],key[1],key[2])
          gff_transcript = @gff.transcript(info[0],info[1],info[2])
          if geneinfo_transcript == gff_transcript
            @strong_TP[0] += 1
            @weak_TP[0] += 1
            number_of_spliceforms = (key[2].split(".")[1].to_f / 1000).ceil
            @strong_TP[number_of_spliceforms] += 1
            @weak_TP[number_of_spliceforms] += 1
            @gff.index.delete(info)
            break
          end
        end
      end
    end
    @strong_TP
  end

  def statistics_weak()
    @gff.index.each_key do |info|    
      @geneinfo.index.each_key do |key|
        if key[0] == info[0] && is_within?(key[1],info[1])
          geneinfo_transcript= @geneinfo.transcript(key[0],key[1],key[2])
          gff_transcript = @gff.transcript(info[0],info[1],info[2])
          geneinfo_transcript = geneinfo_transcript[1..-2]
          gff_transcript = gff_transcript[1..-2]
          if geneinfo_transcript == gff_transcript
            @weak_TP[0] += 1
            number_of_spliceforms = (key[2].split(".")[1].to_f / 1000).ceil
            @weak_TP[number_of_spliceforms] += 1
            @gff.index.delete(info)
            break
          end
        end
      end
    end
    @weak_TP
  end

  def statistics_fp()
    @gff.index.each_key do |info|    
      @geneinfo.index.each_key do |key|
        if key[0] == info[0] && is_within?(key[1],info[1])
          geneinfo_transcript= @geneinfo.transcript(key[0],key[1],key[2])
          @all_FP[0] += 1
          number_of_spliceforms = (key[2].split(".")[1].to_f / 1000).ceil
          @all_FP[number_of_spliceforms] += 1
          @gff.index.delete(info)
          break
        end
      end
    end
    @all_FP[0] += @gff.index.length
    @all_FP
  end
end