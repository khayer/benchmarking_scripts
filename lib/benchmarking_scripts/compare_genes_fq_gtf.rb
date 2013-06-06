require 'gnuplot'
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
          truth_genefile_transcript = @truth_genefile.transcript(key[0],key[1],key[2])
          gff_transcript = @compare_file.transcript(info[0],info[1],info[2])
          truth_genefile_transcript = truth_genefile_transcript[1..-2]
          next if truth_genefile_transcript == []
          gff_transcript = gff_transcript[1..-2]
          #logger.debug("NINA")
          #logger.debug(gff_transcript.join("TT"))
          #logger.debug(truth_genefile_transcript.join("TT"))

          if truth_genefile_transcript == gff_transcript
            frag_counts = @truth_genefile.frag_count(key[0],key[1],key[2])
            fpkm1 = @truth_genefile.fpkm_value(truth_genefile_transcript,frag_counts)
            fpkm2 = @compare_file.fpkm_value(info[0],info[1],info[2])
            @fpkm_values << [fpkm1,fpkm2]
            break
          end
        end
      end
    end
  end

  def plot_fpkm(filename)
    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |plot|

        plot.output filename
        plot.terminal 'png'
        plot.title "FPKM"
        plot.ylabel "cufflinks"
        plot.xlabel "truth"
        #plot.xtics 'format "%.0sMbp"'
        plot.xtics 'nomirror'
        plot.ytics 'nomirror'

        #horizontal lines
        plot.arrow 'from 0,0.1 to 50000000,0.1 nohead lt 0 lc 0'
        plot.arrow 'from 0,0.4 to 50000000,0.4 nohead lt 0 lc 2'
        plot.arrow 'from 0,0.9 to 50000000,0.9 nohead lt 0 lc 0'

        x1 = []
        y1 = []
        @fpkm_values.each do |pair|
          x1 << pair[0]
          y1 << pair[1]
        end
        #x2 = f2.get_xdata
        #y2 = f2.get_ydata

        #scale
        #if y1.max > 1
        #  y1 = y1.map{|y| y * (i/y1.max)}
        #end
    #
        #if y2.max > 1
        #  y2 = y2.map{|y| y * (i/y2.max)}
        #end

        plot.data = [

          Gnuplot::DataSet.new( [x1, y1] ) do |ds|
            ds.with= "points lc 2"
            ds.notitle
          end

          #Gnuplot::DataSet.new([x2, y2]) do |ds|
          #  ds.with = "lines lc 3"
          #  ds.notitle
          #end
        ]

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