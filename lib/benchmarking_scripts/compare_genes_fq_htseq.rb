require 'gnuplot'
class CompareGenesFQHTSeq < CompareGenes

  def initialize(feature_quant_file,htseq_file)
    super()
    @truth_genefile = FeatureQuantifications.new(feature_quant_file)
    @compare_file = HTSeq.new(htseq_file)
    @counts = Hash.new
  end

  attr_accessor :counts

  def statistics_counts()
    @truth_genefile.index.each_key do |key|
      name = key[-1]
      logger.debug("Name: #{name} and counts: #{compare_file.counts[name]}, #{truth_genefile.counts[key]} ")
      @counts[name] = [compare_file.counts[name],truth_genefile.counts[key]]
    end
  end

  def plot_counts(filename)
    max_value = 0
    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |plot|

        plot.output filename
        plot.terminal 'png'
        plot.title "FPKM"
        plot.ylabel "htseq"
        plot.xlabel "truth"
        plot.xtics 'nomirror'
        plot.ytics 'nomirror'
        plot.grid 'xtics'
        plot.grid 'ytics'
        x = []
        y = []
        @counts.each do |pair|
          x << pair[0].to_i
          y << pair[1].to_i
        end
        max_value = [x.max,y.max].max
        plot.xrange "[0:#{max_value}]"
        plot.yrange "[0:#{max_value}]"

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