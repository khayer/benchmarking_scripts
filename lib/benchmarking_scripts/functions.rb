module Functions
  FIXNUM_MAX = (2**(0.size * 8 -2) -1)
  FIXNUM_MIN = -(2**(0.size * 8 -2))

  def fpkm(fragment,length_transcript,number_mio_of_reads=50)
    ((fragment.to_f/(length_transcript.to_f/1000))/number_mio_of_reads.to_f).to_f
    #(fragment.to_f/number_mio_of_reads.to_f).to_f
  end

  def x_cov(fragment,trans_length)
    (fragment.to_f*200.0)/(trans_length.to_f)
  end

  def calc_length(transcript)
    length = 0
    #logger.debug(transcript.join("::"))
    (0..transcript.length-1).step(2).to_a.each do |i|
      length += transcript[i+1]-transcript[i]
    end
    length
  end

  def is_within?(pos1, pos2, boundry=1000000)
    (pos1 - pos2).abs() < boundry
  end

  # Matthews correlation coefficient (MCC)
  # http://en.wikipedia.org/wiki/Matthews_correlation_coefficient
  def mcc(tp,tn,fp,fn)
    tp = tp.to_f
    tn = tn.to_f
    fp = fp.to_f
    fn = fn.to_f
    (tp*tn-fp*fn)/Math.sqrt((tp+fp)*(tp+fn)*(tn+fp)*(tn+fn))
  end

  # false negative rate (FNR)
  # FNR=FN/(FN+TP)
  def fnr(fn,tp)
    fn = fn.to_f
    tp = tp.to_f
    fn/(fn+tp)
  end

  # false discovery rate (FDR)
  # FDR = FP/(FP+TP) = 1-PPV
  def fdr(fp,tp)
    fp = fp.to_f
    tp = tp.to_f
    fp/(fp+tp)
  end
end