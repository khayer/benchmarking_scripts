require "benchmarking_scripts"

m = FeatureQuantifications.new("/project/itmatlab/for_katharina/data4paper/EC/simulator_config_featurequantifications_ensembl-mm9_EC")
m.create_index()
m.calculate_M()
m.calculate_coverage()
m.find_number_of_spliceforms()
m.determine_false_negatives()
m.calculate_x_coverage()

save_as("fq.marshal",m)
