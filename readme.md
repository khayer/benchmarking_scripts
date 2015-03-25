## Benchmarking Scripts Manual ##

This repository provides scripts to analyze algorithms for determining expressed full length mRNA splice forms from RNA-Seq data.

### License ###

This source code is licensed under the GNU General Public License [GPL-2.0](http://opensource.org/licenses/gpl-2.0.php).

### Obtaining the scripts ###

To use the code, you can clone the repository to your computer. This will give you the last most stable release.

    git clone git://github.com/khayer/benchmarking_scripts.git

If you want to take advantage of the newest changes checkout the develop branch after cloning the repository.

    cd benchmarking_scripts
    git checkout develop

### Testing the code on your system ###

You can test the code with [rake](http://rake.rubyforge.org/).

    cd benchmarking_scripts
    rake test

### Install ###

Also you can install the executables with rake.

    cd benchmarking_scripts
    rake build

### Updating ###

    cd benchmarking_scripts
    git pull

### Format of files ###

Please see the files in _/test/data_ for an example.

### Usage of the executables ###

#### stats ####

    Usage: bin/stats CMD file1 file2 [OPTIONS]

    CMD
         gff: if file1 is gff format and file2 is geneinfo
         gtf: if file1 is gtf format and file2 is geneinfo
       gfffq: if file1 is gff format and file2 is feature_quant
       gtffq: if file1 is gtf format and file2 is feature_quant
      gffbed: if file1 is gff format and file2 is bed
      gtfbed: if file1 is gtf format and file2 is bed
       bedfq: if file1 is bed format and file2 is feature_quant
      bedbed: if file1 is bed format and file2 is bed
     htseqfq: if file1 is htseq format and file2 is feature_quant

    Options
        -l, --log_file LEVEL             Can also be STDOUT or STDERR
        -p, --png_file FILE              Default is fpkm.png
        -f, --fpkm_values FILE           Default is fpkm_values.txt
        -e, --exclude FILE               File with gene names to ignore.
        -a, --annotation FILE            File with annotation given to the algorithm
        -s, --saved_truth FILE           File in marshal format to load
        -t, --print_TP                   Print all TP's?
        -d, --debug                      running in debug mode?
        -h, --help                       help

##### Example #####

    stats gtffq test/data/test_fq.gtf test/data/test_feature_quant.txt

    stats gffbed test/data/test_bed.gff test/data/test.bed
