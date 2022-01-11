# Execute this script in the root level directory of the git repo
# Provide cache size in bytes as input/s

# Print usage information and examples for running the test bench script
print_usage() {
	echo "Usage: source ./testbench.sh --config_file <config_file_path> --cache_size <size> --cache_associativity <associativity_1> <associativity_2> ..."
	echo "OR"
	echo "Usage: source ./testbench.sh --config_file <config_file_path> --cache_associativity <associativity> --cache_size <size_1> <size_2> ..."
	echo "Examples-"
	echo "source ./testbench.sh --config_file cache.cfg --cache_size 524288 --cache_associativity 1 2 4 8 16 32"
	echo "source ./testbench.sh --config_file cache.cfg --cache_associativity 16 --cache_size 131072 262144 524288"
	echo "Note-"
	echo "Provide the cache size in bytes as input/s"
}

if (( $# < 6 )); then
	if [[ $# != 1 || ($# == 1 && $1 != "--help") ]]; then
		# Error checking on less number of input parameters
		echo "Invalid number of parameters"
	fi
	print_usage
	return
else
	# Error checking on incorrect type of input parameters
	if [[ $1 != "--config_file" || ($3 != "--cache_size" && $3 != "--cache_associativity") || ($5 != "--cache_associativity" && $5 != "--cache_size") || ($3 = $5) ]]; then
		echo "Incorrect parameters"
		print_usage
		return
	else
		echo "Creating folders if not present..."

		# Create folders if not present
		mkdir -p cache_outputs
		mkdir -p cache_outputs/size
		mkdir -p cache_outputs/associativity
		mkdir -p cache_results
		mkdir -p cache_results/size
		mkdir -p cache_results/associativity
		mkdir -p graph_results

		echo "Creation successful"

		# Get the line numbers for the size and associativity parameters from
		# the cache config file
		size_line="$(grep -n -- "-size (bytes)" $2 | cut -d ":" -f 1)"
		associativity_line="$(grep -n -- "-associativity" $2 | cut -d ":" -f 1)"

		if [[ $5 == "--cache_size" ]]; then
			# Error checking for valid values of cache size
			for i in "${@:6}"; do
				if (( $i <= 0 || $i & ($i - 1) != 0 )); then
					echo "Incorrect value for cache size: $i"
					echo "Value must be > 0 and power of 2"
					return
				fi
			done
			if (( $4 < 0 || $4 & ($4 - 1) != 0 )); then
				echo "Incorrect value for cache associativity: $4"
				echo "Value must be >= 0 and power of 2"
				return
			fi

			echo "Performing cleanup of old result and output files..."

			# Clear the cache size outputs directory if output files are present
			if [ -n "$(ls cache_outputs/size/*.out 2>/dev/null)" ]
			then
				rm -f cache_outputs/size/*.out
			fi
			# Just this should also work
			# rm -f cache_outputs/size/*.out 2>/dev/null

			# Clear the cache size results directory if result files are present
			if [ -n "$(ls cache_results/size/*.cfg.out 2>/dev/null)" ]
			then
				rm -f cache_results/size/*.cfg.out
			fi
			
			echo "Cleanup successful"

			echo "Generating new result and output files for varying size and constant associativity..."

			# Replacing the required parameter values in the same cache config
			# file and generating result and output files
			for i in "${@:6}"; do
				sed -i "${size_line}s/.*/-size (bytes) $i/" $2
				sed -i "${associativity_line}s/.*/-associativity $4/" $2

				output_file="cache_outputs/size/size_$i.out"
				./cacti -infile $2 > $output_file
				curr_result_file="$2.out"
				fin_result_file="cache_results/size/size_$i.cfg.out"
				mv $curr_result_file $fin_result_file
			done

			echo "Generation successful"

			echo "Plotting graphs for the results..."

			python3 plot_results.py cache_size

			echo "Graph plotting done"
		else
			# Error checking for valid values of cache associativity
			for i in "${@:6}"; do
				if (( $i < 0 || $i & ($i - 1) != 0 )); then
					echo "Incorrect value for cache associativity: $i"
					echo "Value must be >= 0 and power of 2"
					return
				fi
			done
			if (( $4 <= 0 || $4 & ($4 - 1) != 0 )); then
				echo "Incorrect value for cache size: $4"
				echo "Value must be > 0 and power of 2"
				return
			fi
			
			echo "Performing cleanup of old result and output files..."

			# Clear the cache associativity outputs directory if output files are present
			if [ -n "$(ls cache_outputs/associativity/*.out 2>/dev/null)" ]
			then
				rm -f cache_outputs/associativity/*.out
			fi
			
			# Clear the cache associativity results directory if result files are present
			if [ -n "$(ls cache_results/associativity/*.cfg.out 2>/dev/null)" ]
			then
				rm -f cache_results/associativity/*.cfg.out
			fi

			echo "Cleanup successful"
			
			echo "Generating new result and output files for varying associativity and constant size..."

			# Replacing the required parameter values in the same cache config
			# file and generating result and output files
			for i in "${@:6}"; do
				sed -i "${size_line}s/.*/-size (bytes) $4/" $2
				sed -i "${associativity_line}s/.*/-associativity $i/" $2

				output_file="cache_outputs/associativity/associativity_$i.out"
				./cacti -infile $2 > $output_file
				curr_result_file="$2.out"
				fin_result_file="cache_results/associativity/associativity_$i.cfg.out"
				mv $curr_result_file $fin_result_file
			done
			
			echo "Generation successful"
			
			echo "Plotting graphs for the results..."

			python3 plot_results.py cache_associativity

			echo "Graph plotting done"
		fi
	fi
fi
