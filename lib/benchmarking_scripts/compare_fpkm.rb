class CompareFPKM
  def initialize()
    @fpkm_values = []
    @fpkm_values_1_spliceform = []
    @fpkm_values_else_spliceform = []
    #@strong_TP_by_cov = []
    #@weak_TP_by_cov = []
    #@all_FP_by_cov = []
    #@false_negatives_by_cov = []
    #@strong_TP_by_x_cov = []
    #@weak_TP_by_x_cov = []
    #@all_FP_by_x_cov = []
    #@false_negatives_by_x_cov = []
  end

  attr_accessor :compare_file, :truth_genefile, :fpkm_values

  def statistics_fpkm()
    logger.info("statistics_fpkm just started!")
    @compare_file.coverage_quantifiers.each_pair do |key,value|
      fpkm1 = @truth_genefile.coverage_quantifiers[key]
      fpkm1 ||= 0.0
      fpkm2 = value
      @fpkm_values << [key,fpkm1,fpkm2]
    end
  end

  def print_fpkm()
    k = "Gene\tTruth\tEstimate\n"
    @fpkm_values.each do |array|
      k += array.join("\t") + "\n"
    end
    k
  end


  #def plot_fn_rate(filename)
  #  x = []
  #  y = []
  #  num_of_fn = @truth_genefile.number_of_false_negatives
  #  @false_negatives_by_cov.each_with_index do |false_negatives,i|
  #    x << i
  #    num_of_must_haves = (false_negatives.to_f+@weak_TP_by_cov[i].to_f)
  #    num_of_must_haves = num_of_fn if num_of_must_haves > num_of_fn
  #    y << false_negatives.to_f/num_of_must_haves
  #  end
  #  Gnuplot.open do |gp|
  #    Gnuplot::Plot.new( gp ) do |plot|
  #      plot.output filename
  #      plot.terminal 'png'
  #      plot.title "False Negative Rate by Coverage"
  #      plot.ylabel "FNR"
  #      plot.xlabel "coverage log"
  #      plot.xtics 'nomirror'
  #      plot.ytics 'nomirror'
  #      plot.grid 'xtics'
  #      plot.grid 'ytics'
  #      plot.data = [
  #        Gnuplot::DataSet.new( [x, y] ) do |ds|
  #          ds.with = "linespoints"
  #          ds.notitle
  #        end
  #      ]
  #    end
  #  end
#
#
  #end
#
  #def plot_fpkm(filename)
  #  max_value = 0
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
  #      plot.grid 'xtics'
  #      plot.grid 'ytics'
  #      x = []
  #      y = []
  #      @fpkm_values.each do |pair|
  #        x << Math.log(pair[1]+1)
  #        y << Math.log(pair[2]+1)
  #      end
  #      max_value = [x.max,y.max].max
  #      plot.xrange "[-0.5:#{max_value}]"
  #      plot.yrange "[-0.5:#{max_value}]"
#
  #      plot.data = [
  #        Gnuplot::DataSet.new( [x, y] ) do |ds|
  #          ds.with= "points lc 2"
  #          ds.notitle
  #        end
  #      ]
  #    end
  #  end
  #  Gnuplot.open do |gp|
  #    Gnuplot::Plot.new( gp ) do |plot|
  #      filename_1 =  filename + "1_spliceform.png"
  #      plot.output filename_1
  #      plot.terminal 'png'
  #      plot.title "FPKM - 1_spliceform"
  #      plot.ylabel "cufflinks"
  #      plot.xlabel "truth"
  #      plot.xtics 'nomirror'
  #      plot.ytics 'nomirror'
  #      plot.grid 'xtics'
  #      plot.grid 'ytics'
  #      x = []
  #      y = []
  #      @fpkm_values_1_spliceform.each do |pair|
  #        x << Math.log(pair[1]+1)
  #        y << Math.log(pair[2]+1)
  #      end
  #      plot.xrange "[-0.5:#{max_value}]"
  #      plot.yrange "[-0.5:#{max_value}]"
#
  #      plot.data = [
  #        Gnuplot::DataSet.new( [x, y] ) do |ds|
  #          ds.with= "points lc 2"
  #          ds.notitle
  #        end
  #      ]
  #    end
  #  end
  #  Gnuplot.open do |gp|
  #    Gnuplot::Plot.new( gp ) do |plot|
  #      filename_2 = filename + "more_than_1_spliceform.png"
  #      plot.output filename_2
  #      plot.terminal 'png'
  #      plot.title "FPKM - more than 1_spliceform"
  #      plot.ylabel "cufflinks"
  #      plot.xlabel "truth"
  #      plot.xtics 'nomirror'
  #      plot.ytics 'nomirror'
  #      plot.grid 'xtics'
  #      plot.grid 'ytics'
  #      x = []
  #      y = []
  #      @fpkm_values_else_spliceform.each do |pair|
  #        x << Math.log(pair[1]+1)
  #        y << Math.log(pair[2]+1)
  #      end
  #      plot.xrange "[-0.5:#{max_value}]"
  #      plot.yrange "[-0.5:#{max_value}]"
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