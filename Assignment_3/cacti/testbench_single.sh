if [ "$#" -ne 4 ]; then
	echo "Invalid number of parameters"
	echo "Usage: source ./testbench_single.sh --config_file <config_file_path> --cache_size/--cache_associativity <size/associativity>"
	return
else
	if [[ $1 != "--config_file" || ($3 != "--cache_size" && $3 != "--cache_associativity") ]]; then
		echo "Incorrect parameters"
		echo "Usage: source ./testbench_single.sh --config_file <config_file_path> --cache_size/--cache_associativity <size/associativity>"
		return
	else
		size_line="$(grep -n -- "-size (bytes)" cache.cfg | cut -d ":" -f 1)"
		associativity_line="$(grep -n -- "-associativity" cache.cfg | cut -d ":" -f 1)"

		if [[ $3 == "--cache_size" ]]; then
			if (( $4 <= 0 || $4 & ($4 - 1) != 0 )); then
				echo "Incorrect value for cache size"
				echo "Value must be > 0 and power of 2"
				return
			fi
			sed -i "${size_line}s/.*/-size (bytes) $4/" $2
			sed -i "${associativity_line}s/.*/-associativity 16/" $2
		else
			if (( $4 < 0 || $4 & ($4 - 1)  != 0 )); then
				echo "Incorrect value for cache associativity"
				echo "Value must be >= 0 and power of 2"
				return
			fi
			sed -i "${size_line}s/.*/-size (bytes) 524288/" $2
			sed -i "${associativity_line}s/.*/-associativity $4/" $2
		fi
	fi
fi

