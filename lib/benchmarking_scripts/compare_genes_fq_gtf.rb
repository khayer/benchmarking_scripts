require 'gnuplot'
class CompareGenesFQGTF < CompareGenes

  def initialize(feature_quant_file,gtf_file)
    super()
    @truth_genefile = FeatureQuantifications.new(feature_quant_file)
    @compare_file = GTF.new(gtf_file)
    @fpkm_values = []
    @fpkm_values_1_spliceform = []
    @fpkm_values_else_spliceform = []
    @strong_TP_by_cov = []
    @weak_TP_by_cov = []
    @all_FP_by_cov = []
    @false_negatives_by_cov = []
  end

  attr_accessor :fpkm_values, :strong_TP_by_cov, :weak_TP_by_cov,
    :all_FP_by_cov, :false_negatives_by_cov

  def statistics_fpkm()
    compare_transcripts = Hash.new
    @compare_file.index.each_key do |key|
      compare_transcripts[key] = @compare_file.transcript(key)
      #puts "compare_ :#{compare_transcripts[key].join('||')}" if compare_transcripts[key][0] == "146047732"
    end
    truth_transcripts = Hash.new
    @truth_genefile.index.each_key do |key|
      truth_transcripts[key] = @truth_genefile.transcript(key)
      #puts "truth :#{truth_transcripts[key].join('||')}" if truth_transcripts[key].length == 2
    end
    truth_transcripts.each_pair do |key, value|
      #puts value.join("||") if value.length == 2
      if compare_transcripts.has_value?(value)
        #puts "WUHU" if value.length == 2
        fpkm1 = @truth_genefile.coverage[key]
        compare_key = compare_transcripts.key(value)
        fpkm2 = @compare_file.coverage[compare_key]
        if key[0] != compare_key[0]
          #puts "YES it happens! #{key} & #{compare_key}"
          next
        end
        @fpkm_values << [key,fpkm1,fpkm2]
        truth_transcripts.delete(key)
        compare_transcripts.delete(compare_key)
        if @truth_genefile.number_of_spliceforms[key] > 1
          @fpkm_values_else_spliceform << [key,fpkm1,fpkm2]
        else
          @fpkm_values_1_spliceform << [key,fpkm1,fpkm2]
        end
      end
    end
    compare_transcripts.each_key do |key|
      compare_transcripts[key] = compare_transcripts[key][1..-2]
    end
    truth_transcripts.each_key do |key|
      truth_transcripts[key] = truth_transcripts[key][1..-2]
    end
    truth_transcripts.each_pair do |key, value|
      if compare_transcripts.has_value?(value)
        fpkm1 = @truth_genefile.coverage[key]
        compare_key = compare_transcripts.key(value)
        fpkm2 = @compare_file.coverage[compare_key]
        if key[0] != compare_key[0]
          #puts "YES it happens! #{key} & #{compare_key}"
          next
        end
        @fpkm_values << [key,fpkm1,fpkm2]
        truth_transcripts.delete(key)
        compare_transcripts.delete(compare_key)
        if @truth_genefile.number_of_spliceforms[key] > 1
          @fpkm_values_else_spliceform << [key,fpkm1,fpkm2]
        else
          @fpkm_values_1_spliceform << [key,fpkm1,fpkm2]
        end
      else
        logger.info("It happens for #{key}")
        fpkm1 = @truth_genefile.coverage[key]
        fpkm2 = 0
        @fpkm_values << [key,fpkm1,fpkm2]
        if @truth_genefile.number_of_spliceforms[key] > 1
          @fpkm_values_else_spliceform << [key,fpkm1,fpkm2]
        else
          @fpkm_values_1_spliceform << [key,fpkm1,fpkm2]
        end
      end
    end
    compare_transcripts.each_pair do |key, value|
      fpkm1 = 0
      fpkm2 = @compare_file.coverage[key]
      @fpkm_values << [key,fpkm1,fpkm2]
    end
  end


  def plot_fn_rate(filename)
    x = []
    y = []
    num_of_fn = @truth_genefile.number_of_false_negatives
    @false_negatives_by_cov.each_with_index do |false_negatives,i|
      x << i
      num_of_must_haves = (false_negatives.to_f+@weak_TP_by_cov[i].to_f)
      num_of_must_haves = num_of_fn if num_of_must_haves > num_of_fn
      y << false_negatives.to_f/num_of_must_haves
    end
    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |plot|
        plot.output filename
        plot.terminal 'png'
        plot.title "False Negative Rate by Coverage"
        plot.ylabel "FNR"
        plot.xlabel "coverage log"
        plot.xtics 'nomirror'
        plot.ytics 'nomirror'
        plot.grid 'xtics'
        plot.grid 'ytics'
        plot.data = [
          Gnuplot::DataSet.new( [x, y] ) do |ds|
            ds.with = "linespoints"
            ds.notitle
          end
        ]
      end
    end


  end

  def plot_fpkm(filename)
    max_value = 0
    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |plot|

        plot.output filename
        plot.terminal 'png'
        plot.title "FPKM"
        plot.ylabel "cufflinks"
        plot.xlabel "truth"
        plot.xtics 'nomirror'
        plot.ytics 'nomirror'
        plot.grid 'xtics'
        plot.grid 'ytics'
        x = []
        y = []
        @fpkm_values.each do |pair|
          x << Math.log(pair[1]+1)
          y << Math.log(pair[2]+1)
        end
        max_value = [x.max,y.max].max
        plot.xrange "[-0.5:#{max_value}]"
        plot.yrange "[-0.5:#{max_value}]"

        plot.data = [
          Gnuplot::DataSet.new( [x, y] ) do |ds|
            ds.with= "points lc 2"
            ds.notitle
          end
        ]
      end
    end
    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |plot|
        filename_1 =  filename + "1_spliceform.png"
        plot.output filename_1
        plot.terminal 'png'
        plot.title "FPKM - 1_spliceform"
        plot.ylabel "cufflinks"
        plot.xlabel "truth"
        plot.xtics 'nomirror'
        plot.ytics 'nomirror'
        plot.grid 'xtics'
        plot.grid 'ytics'
        x = []
        y = []
        @fpkm_values_1_spliceform.each do |pair|
          x << Math.log(pair[1]+1)
          y << Math.log(pair[2]+1)
        end
        plot.xrange "[-0.5:#{max_value}]"
        plot.yrange "[-0.5:#{max_value}]"

        plot.data = [
          Gnuplot::DataSet.new( [x, y] ) do |ds|
            ds.with= "points lc 2"
            ds.notitle
          end
        ]
      end
    end
    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |plot|
        filename_2 = filename + "more_than_1_spliceform.png"
        plot.output filename_2
        plot.terminal 'png'
        plot.title "FPKM - more than 1_spliceform"
        plot.ylabel "cufflinks"
        plot.xlabel "truth"
        plot.xtics 'nomirror'
        plot.ytics 'nomirror'
        plot.grid 'xtics'
        plot.grid 'ytics'
        x = []
        y = []
        @fpkm_values_else_spliceform.each do |pair|
          x << Math.log(pair[1]+1)
          y << Math.log(pair[2]+1)
        end
        plot.xrange "[-0.5:#{max_value}]"
        plot.yrange "[-0.5:#{max_value}]"

        plot.data = [
          Gnuplot::DataSet.new( [x, y] ) do |ds|
            ds.with= "points lc 2"
            ds.notitle
          end
        ]
      end
    end
  end
end