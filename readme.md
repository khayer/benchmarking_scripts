## Benchmarking Scripts Manual ##

This repository provides scripts to analyze algorithms for determining expressed full length mRNA splice forms from RNA-Seq data.

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

## stats ##

    Usage: stats CMD file1 file2 [OPTIONS]

    CMD
        gff: if file1 is gff format
        gtf: if file1 is gtf format

    Options
      -l, --log_file LEVEL             Can also by STDOUT or STDERR
      -d, --debug                      running in debug mode?
      -h, --help                       help
