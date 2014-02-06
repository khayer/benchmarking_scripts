#!/usr/bin/env ruby
require 'optparse'
require 'logger'
require 'spreadsheet'
require "csv"
require 'set'
require "benchmarking_scripts"

# 2014/2/4 Katharina Hayer

$logger = Logger.new(STDERR)
$truth_sequences = Hash.new()
$number_of_spliceforms = Hash.new()

# Initialize logger
def setup_logger(loglevel)
  case loglevel
  when "debug"
    $logger.level = Logger::DEBUG
  when "warn"
    $logger.level = Logger::WARN
  when "info"
    $logger.level = Logger::INFO
  else
    $logger.level = Logger::ERROR
  end
end

def setup_options(args)
  options = {:out_file =>  "STDOUT",:file_format => 'gtf', :log_level => "info"}

  opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: find_TP_cap3 [options] contigs truth_sequences_fa geneinfo.gtf"
    #opts.banner = "Usage: compare_fpkm_values [options] fpkm_values.txt"
    opts.separator ""

    opts.on("-o", "--out_file [OUT_FILE]",
      :REQUIRED,String,
      "File for the output, Default: STDOUT") do |anno_file|
      options[:out_file] = anno_file
    end

    opts.on("-f", "--file_format [FORMAT]",:REQUIRED,String,
      "File format (Avail: gtf, geneinfo, bed, feature_quant) Default: gtf") do |format|
      raise "File format #{format} is not availabe!" unless ['gtf', 'geneinfo', 'bed',
       'feature_quant'].include?(format)
      options[:file_format] = format
    end

    opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
      options[:log_level] = "info"
    end

    opts.on("-d", "--debug", "Run in debug mode") do |v|
      options[:log_level] = "debug"
    end
  end

  args = ["-h"] if args.length == 0
  opt_parser.parse!(args)
  raise "Please specify the sam files" if args.length == 0
  options
end

#### METHODS

=begin
def search_in(current_sequence)
  result = [0, ""]
  current_sequence_complement = get_reverse_complement(current_sequence)
  ind1 = $truth_sequences.key(current_sequence_complement)
  ind2 = $truth_sequences.key(current_sequence)
  if ind1
    $truth_sequences.delete(ind1)
    #$truth_sequences.delete(ind2)
    result = [2, ind1]
  elsif ind2
    $truth_sequences.delete(ind2)
    result = [2, ind2]
  else
    begin
      current_sequence_regexp = Regexp.new current_sequence
      current_sequence_complement_regexp = Regexp.new current_sequence_complement
      matching_sequence = $truth_sequences.inject([]) { |res, kv| res << kv if (kv[1] =~ current_sequence_regexp || kv[1] =~ current_sequence_complement_regexp); res  }
    rescue
      matching_sequence = $truth_sequences.inject([]) { |res, kv| res << kv unless (kv[1].scan(current_sequence).empty?) && (kv[1].scan(current_sequence_complement).empty?); res  }
    end
    matching_sequence.flatten!
    if matching_sequence[1]
      if length_diff(matching_sequence[1],current_sequence) > 500
        result = [0, matching_sequence[0]]
      #elsif length_diff(matching_sequence[1],current_sequence) == 0
      #  result = [2, matching_sequence[0]]
      #  $truth_sequences.delete(matching_sequence[0])
      else
        result = [1, matching_sequence[0]]
        $truth_sequences.delete(matching_sequence[0])
      end
    end
  end


  #if helper
  #ind1 = $truth_sequences.index(current_sequence_complement)
  #ind2 = $truth_sequences.index(current_sequence)
  #if ind1
  #  $truth_sequences.delete(ind1)
  #  $truth_sequences.delete(ind2)
  #  result = [2, ind1]
  #elsif ind2
  #  $truth_sequences.delete(ind2)
  #  result = [2, ind2]
  #else
  #  $truth_sequences.each do |key, sequence|
  #    next if current_sequence.length > sequence.length
  #    #if sequence == current_sequence || sequence == current_sequence_complement
  #    #  $truth_sequences.delete(key)
  #    #  result = [2, key]
  #    #  break
  #    #end
#
  #    current_sequence_regexp = Regexp.new current_sequence
  #    current_sequence_complement_regexp = Regexp.new current_sequence_complement
  #    if (sequence  =~ current_sequence_regexp) || (sequence  =~ current_sequence_complement_regexp)
  #      if length_diff(sequence,current_sequence) > 500
  #        result = [0, key]
  #        break
  #      else
  #        $truth_sequences.delete(key)
  #        result = [1, key]
  #        break
  #      end
  #    end
  #  end
  #end
  result
end
=end

def length_diff(seq1,seq2)
  (seq1.length - seq2.length).abs
end

def get_reverse_complement(seq)
  seq_complement = ""
  seq.split("").reverse.each do |base|
    case base
    when "A"
      seq_complement += "T"
    when "T"
      seq_complement += "A"
    when "C"
      seq_complement += "G"
    when "G"
      seq_complement += "C"
    end
  end
  seq_complement
end

def read_anno(geneinfo,file_format)
  case file_format
  when "gtf"
    genes_anno = GTF.new(geneinfo)
  when "geneinfo"
    genes_anno = GeneInfo.new(geneinfo)
  when "feature_quant"
    genes_anno = FeatureQuantifications.new(geneinfo)
  else
    raise "File format #{file_format} not supported yet!"
  end
  genes_anno.create_index()
  genes_anno.find_number_of_spliceforms()
  genes_anno
end

def get_truth_sequences(truth_sequences_file)
  key = ""
  $logger.info("Adding sequences...")
  File.open(truth_sequences_file).each do |line|
    line.chomp!
    if line =~ /^>/
      key = line.split(":")[0].split(">")[1] #>GENE.1.0:chr1:4797973-4836816_+
    else
      $truth_sequences[key] = line.upcase
    end
  end
  $logger.info("Done: Adding sequences...")
end

def cut_truth_sequences(genes_anno)
  $logger.info("Cutting sequences ...")
  genes_anno.index.each_key do |key|
    transcript = genes_anno.transcript(key)
    pre_cut_seq = $truth_sequences[key[-1]]
    seq_length = pre_cut_seq.length
    start = transcript[1]-transcript[0]-50
    stop = seq_length-(transcript[-1]-transcript[-2]-50)
    $logger.debug("key[-1] #{key[-1]}")
    $truth_sequences[key[-1]] = Regexp.new pre_cut_seq[start..stop]
    $number_of_spliceforms[key[-1]] = genes_anno.number_of_spliceforms[key]
  end
  $logger.info("Done with cutting!")
end

def search(current_sequence)
  gene_name = ""
  complement = get_reverse_complement(current_sequence)
  $truth_sequences.each_pair do |key,value|
    reg_val = value
    $logger.debug("value #{value}")
    gene_name = key if complement =~ reg_val
    gene_name = key if current_sequence =~ reg_val
    if gene_name != ""
      $truth_sequences.delete(key)
      break
    end
  end
  gene_name
end

#### MAIN

def run(argv)
  options = setup_options(argv)
  setup_logger(options[:log_level])
  $logger.debug(options)
  $logger.debug(argv)
  #puts options[:cut_off]
  #read_fpkm_values(argv[0])

  contig_file = ARGV[0]
  truth_sequences_file = ARGV[1]
  geneinfo = ARGV[2]

  genes_anno = read_anno(geneinfo,options[:file_format])
  get_truth_sequences(truth_sequences_file)
  cut_truth_sequences(genes_anno)


  #$expressed_isoforms = []
  #File.open(rsem).each do |line|
  #  next unless line =~ /^comp/
  #  line.chomp!
  #  info = line.split("\t")
  #  iso_pct = info[-1].to_f
  #  $expressed_isoforms << info[0] if iso_pct > 50.00
  #end


  number_of_transcripts = `grep -c "^>" #{contig_file}`

  current_sequence = ""
  false_positive = 0
  weak_true_positive = 0
  strong_true_positive = 0
  weak_true_positive_by_spliceform = []
  #strong_true_positives_by_spliceforms = []
  #weak_false_positives_by_spliceforms = []

  number_of_all_genes = 0
  current_comp_name = ""

  File.open(contig_file).each do |line|

    line.chomp!
    if line =~ /^>/ && current_sequence != "" #&& $expressed_isoforms.include?(current_comp_name)
      number_of_all_genes += 1
      $logger.info("#{( number_of_all_genes.to_f / number_of_transcripts.to_f )*100} %")
      gene_name = search(current_sequence)
      if gene_name.empty?
        false_positive += 1
      else
        weak_true_positive_by_spliceform[$number_of_spliceforms[gene_name]] = 0 unless weak_true_positive_by_spliceform[$number_of_spliceforms[gene_name]]
        weak_true_positive_by_spliceform[$number_of_spliceforms[gene_name]] += 1
      end
    end
    #  #STDERR.puts "#{( number_of_all_genes.to_f / 66 ).to_f} %"
    #  result = search_in(current_sequence)
    #  current_sequence = ""
    #  case result[0]
    #  when 0
    #    #puts "NEGATIVE"
    #    false_positive += 1
    #    #if result[1] != ""
    #    #STDERR.puts result.join(":")
    #    if result[1] =~ /GENE/
    #      number = (result[1].split(".")[1].to_i / 1000).floor + 1 #GENE.1802.1
    #    else
    #      #STDERR.puts "fdsfdgg"
    #      number = 0
    #    end
    #    #puts number
    #    weak_false_positives_by_spliceforms[number] = 0 unless weak_false_positives_by_spliceforms[number]
    #    weak_false_positives_by_spliceforms[number] += 1
    #    #end
    #  when 1
    #    #puts "WEAK"
    #    weak_true_positive += 1
    #    number = (result[1].split(".")[1].to_i / 1000).floor + 1 #GENE.1802.1
    #    #puts number
    #    weak_true_positive_by_spliceform[number] = 0 unless weak_true_positive_by_spliceform[number]
    #    weak_true_positive_by_spliceform[number] += 1
    #  when 2
    #    #puts "STRONG"
    #    strong_true_positive += 1
    #    weak_true_positive += 1
    #    number = (result[1].split(".")[1].to_i / 1000).floor + 1 #GENE.1802.1
    #    #puts number
    #    weak_true_positive_by_spliceform[number] = 0 unless weak_true_positive_by_spliceform[number]
    #    weak_true_positive_by_spliceform[number] += 1
    #    strong_true_positives_by_spliceforms[number] = 0 unless strong_true_positives_by_spliceforms[number]
    #    strong_true_positives_by_spliceforms[number] += 1
    #  end
    #end



    if line =~ /^>/
      current_comp_name = line.split(" ")[0].split(">")[1]
      current_sequence = ""
      next
    end
    current_sequence += line.upcase
  end

  #result = search_in(current_sequence)
  #current_sequence = ""
  #case result[0]
  #when 0
  #  #puts "NEGATIVE"
  #  false_positive += 1
  #  #if result[1] != ""
  #  number = (result[1].split(".")[1].to_i / 1000).floor + 1 #GENE.1802.1
  #  #puts number
  #  weak_false_positives_by_spliceforms[number] = 0 unless weak_false_positives_by_spliceforms[number]
  #  weak_false_positives_by_spliceforms[number] += 1
  #  #end
  #when 1
  #  #puts "WEAK"
  #  weak_true_positive += 1
  #  number = (result[1].split(".")[1].to_i / 1000).floor + 1 #GENE.1802.1
  #  #puts number
  #  weak_true_positive_by_spliceform[number] = 0 unless weak_true_positive_by_spliceform[number]
  #  weak_true_positive_by_spliceform[number] += 1
  #when 2
  #  #puts "STRONG"
  #  strong_true_positive += 1
  #  weak_true_positive += 1
  #  number = (result[1].split(".")[1].to_i / 1000).floor + 1 #GENE.1802.1
  #  #puts number
  #  weak_true_positive_by_spliceform[number] = 0 unless weak_true_positive_by_spliceform[number]
  #  weak_true_positive_by_spliceform[number] += 1
  #  strong_true_positives_by_spliceforms[number] = 0 unless strong_true_positives_by_spliceforms[number]
  #  strong_true_positives_by_spliceforms[number] += 1
  #end

  #puts false_positive
  #puts weak_true_positive
  #puts strong_true_positive

  puts "=========="
  puts "By number of splice forms:"
  puts "\t\t#{(1..10).to_a.join("\t")}"
  #puts "StroTP\t#{strong_true_positives_by_spliceforms.join("\t")}"
  puts "WeakTP\t#{weak_true_positive_by_spliceform.join("\t")}"
  #puts "allFP\t#{weak_false_positives_by_spliceforms.join("\t")}"
  puts "=========="
  #puts "Strongly True Positives\t#{strong_true_positive}"
  #puts "Weak True Positives\t#{weak_true_positive}"
  puts "All False Positives\t#{false_positive}"
  puts "=========="
  puts "All transcripts\t#{number_of_all_genes}"

end

if __FILE__ == $0
  run(ARGV)
end
