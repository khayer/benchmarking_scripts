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
$EXCLUDE_GENES = []

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
  genes_anno.calculate_M()
  #compare_obj.truth_genefile.calculate_coverage(50)
  genes_anno.calculate_coverage()
  genes_anno.determine_false_negatives(5000)
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
    if transcript.length > 2
      pre_cut_seq = $truth_sequences[key[-1]]
      seq_length = pre_cut_seq.length
      start = transcript[1]-transcript[0]-25
      stop = seq_length-(transcript[-1]-transcript[-2]-25)
      #$logger.debug("key[-1] #{key[-1]}")
      $truth_sequences[key[-1]] = Regexp.new pre_cut_seq[start..stop]
      $number_of_spliceforms[key[-1]] = genes_anno.number_of_spliceforms[key]
    else
      $truth_sequences[key[-1]] = Regexp.new $truth_sequences[key[-1]]
      $number_of_spliceforms[key[-1]] = genes_anno.number_of_spliceforms[key]
    end
  end
  $logger.info("Done with cutting!")
end

def search(current_sequence, genes_anno)
  gene_name = ""
  complement = get_reverse_complement(current_sequence)
  $logger.debug("New round for #{current_sequence[0..100]}...")
  $truth_sequences.each_pair do |key,value|
    reg_val = value
    #$logger.debug("value #{value}")

    gene_name = key if complement =~ reg_val
    gene_name = key if current_sequence =~ reg_val
    #$logger.info("GENE_NAME #{gene_name}")
    #STDIN.gets
    if gene_name != ""
      $truth_sequences.delete(key)
      genes_anno.false_negatives.delete(key)
      break
    end
  end
  gene_name
end

def run_makeblastdb(sequences, index_home, title)
  cmd = "makeblastdb -dbtype nucl -in #{sequences} -input_type fasta -title #{title} -out #{index_home}/#{title}"
  $logger.debug("Cmd: #{cmd}")
  k = `#{cmd}`
end

def run_blastn(query,index_home,title)
  cmd = "blastn -db #{index_home}/#{title} -query #{query} -evalue 0.0000001 -outfmt 6 > test_12345"
  $logger.debug("Cmd: #{cmd}")
  k = `#{cmd}`
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


  sequences = contig_file
  index_home = "~/index"
  title = contig_file.split(".")[0]
  result_makeblastdb = run_makeblastdb(sequences, index_home, title)
  $logger.info("Result: #{result_makeblastdb}")

  genes_anno = read_anno(geneinfo,options[:file_format])
  get_truth_sequences(truth_sequences_file)
  cut_truth_sequences(genes_anno)
  query = "query.fasta"
  query_hand = File.open(query, "w") 
  
  $truth_sequences.each_pair do |key,value|
    query_hand.puts ">#{key}"
    query_hand.puts value
  end
  query_hand.close()
  result_runblastn = run_blastn(query,index_home,title)
  exit
  


  number_of_transcripts = `grep -c "^>" #{contig_file}`

  current_sequence = ""
  false_positive = 0
  weak_true_positive = 0
  strong_true_positive = 0
  weak_true_positive_by_spliceform = [0]
  #strong_true_positives_by_spliceforms = []
  #weak_false_positives_by_spliceforms = []

  number_of_all_genes = 0
  current_comp_name = ""

  File.open(contig_file).each do |line|

    line.chomp!
    if line =~ /^>/ && current_sequence != "" #&& $expressed_isoforms.include?(current_comp_name)
      number_of_all_genes += 1
      $logger.info("#{( number_of_all_genes.to_f / number_of_transcripts.to_f )*100} %")
      $logger.info("false_positive: #{false_positive}; True_positives: #{weak_true_positive_by_spliceform[0]}")
      gene_name = search(current_sequence,genes_anno)
      $logger.info("GENE_NAME #{gene_name}")
      if gene_name == ""
        false_positive += 1
      else
        weak_true_positive_by_spliceform[$number_of_spliceforms[gene_name]] = 0 unless weak_true_positive_by_spliceform[$number_of_spliceforms[gene_name]]
        weak_true_positive_by_spliceform[$number_of_spliceforms[gene_name]] += 1
        weak_true_positive_by_spliceform[0] += 1
      end
    end

    if line =~ /^>/
      current_comp_name = line.split(" ")[0].split(">")[1]
      current_sequence = ""
      next
    end
    current_sequence += line.upcase
  end

  false_negatives = [0]
  genes_anno.false_negatives.each_pair do |key,value|
    false_negatives[0] += 1
    false_negatives[$number_of_spliceforms[key]] = 0 unless false_negatives[$number_of_spliceforms[key]]
    false_negatives[$number_of_spliceforms[key]] += 1
  end

  puts "=========="
  puts "By number of splice forms:"
  puts "\t#{(0..10).to_a.join("\t")}"
  #puts "StroTP\t#{strong_true_positives_by_spliceforms.join("\t")}"
  puts "WeakTP\t#{weak_true_positive_by_spliceform.join("\t")}"
  puts "allFN\t#{false_negatives.join("\t")}"
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
