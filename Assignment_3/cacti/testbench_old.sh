# Execute this script in the root level directory of the git repo

# Add new config files for different configurations of varying size and
# associativity (with constant associativity and size respectively), in the
# folders cache_configs/size and cache_config/associativity respectively

echo "Performing cleanup of old result and output files..."

# Clear the cache size outputs directory if output files are present
if [ -n "$(ls cache_outputs/size/*.out 2>/dev/null)" ]
then
	rm -f cache_outputs/size/*.out
fi
# Just this should also work
# rm -f cache_outputs/size/*.out 2>/dev/null

# Clear the cache associativity outputs directory if output files are present
if [ -n "$(ls cache_outputs/associativity/*.out 2>/dev/null)" ]
then
	rm -f cache_outputs/associativity/*.out
fi

# Clear the cache size results directory if result files are present
if [ -n "$(ls cache_results/size/*.cfg.out 2>/dev/null)" ]
then
	rm -f cache_results/size/*.cfg.out
fi

# Clear the cache associativity results directory if result files are present
if [ -n "$(ls cache_results/associativity/*.cfg.out 2>/dev/null)" ]
then
	rm -f cache_results/associativity/*.cfg.out
fi

echo "Cleanup successful"

echo "Generating new result and output files for varying size and constant associativity..."

# Generate the cacti result and output files for varying size
for size_config_file in cache_configs/size/*.cfg; do
	prefix="$(basename $size_config_file .cfg)"
	output_file="cache_outputs/size/${prefix}.out"
	./cacti -infile "$size_config_file" > $output_file
	curr_result_file="cache_configs/size/${prefix}.cfg.out"
	fin_result_file="cache_results/size/${prefix}.cfg.out"
	mv $curr_result_file $fin_result_file
done

echo "Generation successful"

echo "Generating new result and output files for varying associativity and constant size..."

# Generate the result and output files for varying associativity
for associativity_config_file in cache_configs/associativity/*.cfg; do
	prefix="$(basename $associativity_config_file .cfg)"
	output_file="cache_outputs/associativity/${prefix}.out"
	./cacti -infile "$associativity_config_file" > $output_file
	curr_result_file="cache_configs/associativity/${prefix}.cfg.out"
	fin_result_file="cache_results/associativity/${prefix}.cfg.out"
	mv $curr_result_file $fin_result_file
done

echo "Generation successful"

# The output files will not be used to parse out the required values but are
# saved only for manual reference

echo "Plotting graphs for the results..."

# Call a python script to extract the required values from the saved result
# files for both varying size and associativity and plot graphs accordingly

echo "Graph plotting done"
