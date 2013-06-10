require 'gnuplot'
class CompareGenesFQGFF < CompareGenes

  def initialize(feature_quant_file,gtf_file)
    super()
    @truth_genefile = FeatureQuantifications.new(feature_quant_file)
    @compare_file = GFF.new(gtf_file)
    @strong_TP_by_cov = []
    @weak_TP_by_cov = []
    @all_FP_by_cov = []
    @false_negatives_by_cov = []
  end

  attr_accessor :strong_TP_by_cov, :weak_TP_by_cov, :all_FP_by_cov, :false_negatives_by_cov

  #def statistics_fpkm()
  #  @compare_file.index.each_key do |info|
  #    @truth_genefile.index.each_key do |key|
  #      if key[0] == info[0] && is_within?(key[1],info[1])
  #        truth_genefile_transcript = @truth_genefile.transcript(key[0],key[1],key[2])
  #        gff_transcript = @compare_file.transcript(info[0],info[1],info[2])
  #        truth_genefile_transcript = truth_genefile_transcript[1..-2]
  #        next if truth_genefile_transcript == []
  #        gff_transcript = gff_transcript[1..-2]
  #        #logger.debug("NINA")
  #        #logger.debug(gff_transcript.join("TT"))
  #        #logger.debug(truth_genefile_transcript.join("TT"))
  #        if truth_genefile_transcript == gff_transcript
  #          frag_counts = @truth_genefile.frag_count(key[0],key[1],key[2])
  #          fpkm1 = @truth_genefile.fpkm_value(truth_genefile_transcript,frag_counts)
  #          fpkm2 = @compare_file.fpkm_value(info[0],info[1],info[2])
  #          @fpkm_values << [fpkm1,fpkm2]
  #          break
  #        end
  #      end
  #    end
  #  end
  #end
#
  #def plot_fpkm(filename)
  #  Gnuplot.open do |gp|
  #    Gnuplot::Plot.new( gp ) do |plot|
#
  #      plot.output filename
  #      plot.terminal 'png'
  #      plot.title "FPKM"
  #      plot.ylabel "cufflinks"
  #      plot.xlabel "truth"
  #      plot.xtics 'nomirror'
  #      plot.ytics 'nomirror'
  #      plot.xrange "[0:10]"
  #      plot.yrange "[0:10]"
#
  #      x = []
  #      y = []
  #      @fpkm_values.each do |pair|
  #        x << Math.log(pair[0])
  #        y << Math.log(pair[1])
  #      end
#
  #      plot.data = [
  #        Gnuplot::DataSet.new( [x, y] ) do |ds|
  #          ds.with= "points lc 2"
  #          ds.notitle
  #        end
  #      ]
  #    end
  #  end
  #end
end