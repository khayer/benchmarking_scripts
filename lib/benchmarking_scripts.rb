class BenchmatkingScripts

end

require 'logger'
require 'benchmarking_scripts/logging'
include Logging
require 'benchmarking_scripts/functions'
include Functions
require 'benchmarking_scripts/file_formats'
require 'benchmarking_scripts/gff'
require 'benchmarking_scripts/gtf'
require 'benchmarking_scripts/bed'
require 'benchmarking_scripts/geneinfo'
require 'benchmarking_scripts/compare_genes'
require 'benchmarking_scripts/compare_genes_gff'
require 'benchmarking_scripts/compare_genes_gtf'
require 'benchmarking_scripts/feature_quantifications'
require 'benchmarking_scripts/compare_genes_fq_gtf'
require 'benchmarking_scripts/compare_genes_fq_gff'
require 'benchmarking_scripts/compare_genes_bed_gtf'
require 'benchmarking_scripts/compare_genes_bed_gff'
