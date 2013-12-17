#!/usr/bin/env ruby
require 'optparse'
require 'logger'

$logger = Logger.new(STDERR)

# Splice Junctions:
# ----------------
$donor = Array.new(12)
$donor_rev = Array.new(12)
$acceptor = Array.new(12)
$acceptor_rev = Array.new(12)
# The Canonical:
#  GTAG
#rev: CT AC
$donor[0] = "GT";
$donor_rev[0] = "AC";
$acceptor[0] = "AG";
$acceptor_rev[0] = "CT";
# Other Characterized:
#  GCAG
# rev: CT GC
$donor[1] = "GC";
$donor_rev[1] = "GC";
$acceptor[1] = "AG";
$acceptor_rev[1] = "CT";
#  GCTG
# rev: CA GC
$donor[2] = "GC";
$donor_rev[2] = "GC";
$acceptor[2] = "TG";
$acceptor_rev[2] = "CA";
#  GCAA
# rev: TT GC
$donor[3] = "GC";
$donor_rev[3] = "GC";
$acceptor[3] = "AA";
$acceptor_rev[3] = "TT";
#  GCCG
# rev: CG GC
$donor[4] = "GC";
$donor_rev[4] = "GC";
$acceptor[4] = "CG";
$acceptor_rev[4] = "CG";
#  GTTG
# rev: CA AC
$donor[5] = "GT";
$donor_rev[5] = "AC";
$acceptor[5] = "TG";
$acceptor_rev[5] = "CA";
#  GTAA
# rev: TT AC
$donor[6] = "GT";
$donor_rev[6] = "AC";
$acceptor[6] = "AA";
$acceptor_rev[6] = "TT";
# U12-dependent:
#  ATAC
#rev: GT AT
$donor[7] = "AT";
$donor_rev[7] = "AT";
$acceptor[7] = "AC";
$acceptor_rev[7] = "GT";
#  ATAA
#rev: TT AT
$donor[8] = "AT";
$donor_rev[8] = "AT";
$acceptor[8] = "AA";
$acceptor_rev[8] = "TT";
#  ATAG
# rev: CT AT
$donor[9] = "AT";
$donor_rev[9] = "AT";
$acceptor[9] = "AG";
$acceptor_rev[9] = "CT";
#  ATAT
# rev: ATAT
$donor[10] = "AT";
$donor_rev[10] = "AT";
$acceptor[10] = "AT";
$acceptor_rev[10] = "AT";
#  TAGA
# rev: TC TA
$donor[11] = "TA";
$donor_rev[11] = "TA";
$acceptor[11] = "GA";
$acceptor_rev[11] = "TC";


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
  options = {:out_file =>  "gc_content.txt"}

  opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: #{$0} [options] gtf_file fasta_file"
    opts.separator ""
    opts.separator "calculates gc content for each gene."

    opts.separator ""
    opts.on("-o", "--out_file [OUT_FILE]",
      :REQUIRED,String,
      "File for the output, Default: summary_refseq.txt") do |anno_file|
      options[:out_file] = anno_file
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
  raise "Please specify the input files" if args.length == 0
  options
end

def add_gene(gene_info,name,chromosome,starts,stops)
  gene_info[name] = {:chr => chromosome, :starts => starts,
    :stops => stops, :gc_content => 0.5}
end


def read_gtf_file(gtf_file)
  gene_info = {}
  last_name = nil
  starts = []
  stops = []
  chromosome = nil
  identifier = ""
  File.open(gtf_file).each do |line|
    line.chomp!
    next unless line =~ /exon/
    chr,d,d,start,stop,d,d,d,identifier = line.split("\t")
    identifier = /\w*-\w*/.match(identifier)[0]
    last_name = identifier unless last_name
    if last_name != identifier
      add_gene(gene_info,last_name,chromosome,starts,stops)
      starts = []
      stops = []
      last_name = identifier
    end
    starts << start.to_i
    stops << stop.to_i
    chromosome = chr

  end
  add_gene(gene_info,identifier,chromosome,starts,stops)
  gene_info
end

def read_index(fai_file)
  fai_index = {}
  File.open(fai_file).each do |line|
    line.chomp!
    chr,length,start = line.split("\t")
    length = length.to_i
    start = start.to_i
    fai_index[chr] = {:start => start, :stop => start+length-1}
  end
  fai_index
end

def calculate_gc_content(fai_index,fasta_file,info)
  sequence = ""

  info[:starts].each_with_index do |start,i|
    sequence += fasta_file[fai_index[info[:chr]][:start]..fai_index[info[:chr]][:stop]][start..info[:stops][i]]
  end
  gc_count = sequence.count("GgCc")
  gc_content = gc_count/sequence.length.to_f
end

def get_gene_length(info)
  length = 0
  info[:starts].each_with_index do |start,i|
    length += info[:stops][i] - start
  end
  length
end

def read_gene_info_file(config_file,fasta)
  gene_info={}
  all_introns={}
  introns_novel={}
  fai_index = read_index("#{fasta}.fai")
  $logger.debug("FAI index: #{fai_index}")
  #fasta_file = File.open("/Users/hayer/Downloads/mm9_ucsc.fa").read
  fasta_file = File.open(fasta).read  #lines.map {|e| e.strip }.join("")
  seq_hash = {}
  fai_index.each_pair do |name, index|
    seq_hash[name] = fasta_file[index[:start]..index[:stop]].delete("\n")
  end
  #fasta_file = nina
  File.open(config_file).each do |line|
    line.chomp!
    chr, strand, start,stop,num_exon,
    exon_starts, exon_stops, name = line.split("\t")
    exon_starts = exon_starts.split(",").map { |e| e.to_i }
    exon_stops = exon_stops.split(",").map { |e| (e.to_i) +1 }
    $logger.debug(name)
    for i in 0...num_exon.to_i-1
      #if exon_starts[i+1]-exon_stops[i] < 2000
        #puts name
        #puts exon_starts[i+1]
        #puts exon_stops[i]
        sequence = seq_hash[chr][exon_stops[i]...exon_starts[i+1]]
        #puts sequence
        splice_signal_num_donor = nil
        splice_signal_num_acceptor = nil
        splice_signal_num = -1
        if sequence && sequence.length >= 4
          if strand == "-"
            #reverse case
            for k in 0...$donor_rev.length
              if sequence[-2..-1].upcase == $donor_rev[k] &&
                sequence[0..1].upcase == $acceptor_rev[k]
                splice_signal_num_donor = k
                splice_signal_num_acceptor = k
              end
            end
          else
            for k in 0...$donor_rev.length
              if sequence[0..1].upcase == $donor[k] &&
                sequence[-2..-1].upcase == $acceptor[k]
                splice_signal_num_donor = k
                splice_signal_num_acceptor = k
              end
            end
            #splice_signal_num_donor = $donor.index(sequence[0..1].capitalize)
            #splice_signal_num_acceptor = $acceptor.index(sequence[-2..-1].capitalize)
          end
        end


        if splice_signal_num_donor == splice_signal_num_acceptor && splice_signal_num_acceptor
          splice_signal_num = splice_signal_num_acceptor
        end
        #$logger.debug(splice_signal_num)
        if splice_signal_num == -1
          puts "#{name}\t#{exon_stops[i]}\t#{exon_starts[i+1]}\t#{sequence}\t#{strand}\t#{splice_signal_num}"
          introns_novel[[chr,exon_stops[i],exon_starts[i+1],strand]] ||= 0
          introns_novel[[chr,exon_stops[i],exon_starts[i+1],strand]] += 1
        end
        all_introns[[chr,exon_stops[i],exon_starts[i+1],strand]] ||= 0
        all_introns[[chr,exon_stops[i],exon_starts[i+1],strand]] += 1
        #STDIN.gets
      #end
    end
  end
  puts "All introns: #{all_introns.keys.length}"
  puts "Special: #{introns_novel.keys.length}"
  k = File.open("introns.txt", "w")
  all_introns.keys.each do |el|
    k.puts "#{el[0]}:#{el[1]}-#{el[2]}\t#{el[3]}"
  end
  k.close()
end

def process(gene_info,fasta_file,outfile)
  fai_index = read_index("#{fasta_file}.fai")
  puts "\tlength\tgccontent"
  fasta_file = File.open(fasta_file).read
  i = 0
  gene_info.each_pair do |id, info|
    $logger.debug("Processed #{i} id's") if i % 1000 == 0
    i += 1
    gc_content = calculate_gc_content(fai_index,fasta_file,info)
    length = get_gene_length(info)
    outfile.puts "#{id}\t#{length}\t#{gc_content}"
  end
end

def run(argv)
  options = setup_options(argv)
  setup_logger(options[:log_level])
  $logger.debug(options)
  $logger.debug(argv)
  $logger.debug("Reading gene_info file")
  gene_info = read_gene_info_file(argv[0],argv[1])
  #$logger.debug("Processing ...")
  #outfile = File.open(options[:out_file], "w")
  #gene_info = process(gene_info,argv[1],outfile)

end

if __FILE__ == $0
  run(ARGV)
end
