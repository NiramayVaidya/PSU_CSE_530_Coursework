index_lengths=( 7 8 9 10 11 12 13 14 15 )
history_bits=( 2 4 6 8 10 12 15 )

compute_bimodal_results() {
	echo "BiModal Results-"
	cp -f src/my_predictor.h_bp2 src/my_predictor.h
	echo -e "index_length\tmpki"
	for i in "${index_lengths[@]}"
	do
		cd src/
		sed -i "12s/.*/\t\t#define INDEX_LENGTH\t$i/" my_predictor.h
		make > /dev/null 2>&1
		cd ..
		mpki="$(./run traces/ | tail -n 1 | cut -d ":" -f 2)"
		echo -e "$i\t$mpki"
	done
}

compute_gshare_results() {
	echo "gShare Results-"
	cp -f src/my_predictor.h_bp1 src/my_predictor.h
	echo -e "index_length\thistory_bits\tmpki"
	for i in "${index_lengths[@]}"
	do
		for j in "${history_bits[@]}"
		do
			if (( $j < $i )); then
				cd src/
				sed -i "10s/.*/#define INDEX_LENGTH\t$i/" my_predictor.h
				sed -i "11s/.*/#define HISTORY_BITS\t$j/" my_predictor.h
				make > /dev/null 2>&1
				cd ..
				mpki="$(./run traces/ | tail -n 1 | cut -d ":" -f 2)"
				echo -e "$i\t$j\t$mpki"
			fi
		done
	done
}

compute_yehpatt_results() {
	echo "Yeh-Patt Results-"
	cp -f src/my_predictor.h_bp3 src/my_predictor.h
	echo -e "index_length\thistory_bits\tmpki"
	for i in "${index_lengths[@]}"
	do
		for j in "${history_bits[@]}"
		do
			if (( $j < $i )); then
				cd src/
				sed -i "11s/.*/\t\t#define INDEX_LENGTH\t$i/" my_predictor.h
				sed -i "12s/.*/\t\t#define HISTORY_BITS\t$j/" my_predictor.h
				make > /dev/null 2>&1
				cd ..
				mpki="$(./run traces/ | tail -n 1 | cut -d ":" -f 2)"
				echo -e "$i\t$j\t$mpki"
			fi
		done
	done
}

compute_hybrid_results() {
	echo "Hybrid Results-"
	cp -f src/my_predictor.h_bp4 src/my_predictor.h
	echo -e "index_length\thistory_bits\tmpki"
	for i in "${index_lengths[@]}"
	do
		for j in "${history_bits[@]}"
		do
			if (( $j < $i )); then
				cd src/
				sed -i "15s/.*/\t\t\t\t#define INDEX_LENGTH\t$i/" my_predictor.h
				sed -i "16s/.*/\t\t\t\t#define HISTORY_BITS\t$j/" my_predictor.h
				make > /dev/null 2>&1
				cd ..
				mpki="$(./run traces/ | tail -n 1 | cut -d ":" -f 2)"
				echo -e "$i\t$j\t$mpki"
			fi
		done
	done
}

if (( $# < 1 )); then
	echo "Invalid number of parameters"
	echo "Usage: source ./automate.sh bimodal/gshare/yehpatt/hybrid/all"
	return
fi

if [[ $1 == "bimodal" ]]; then
	compute_bimodal_results
fi

if [[ $1 == "gshare" ]]; then
	compute_gshare_results
fi

if [[ $1 == "yehpatt" ]]; then
	compute_yehpatt_results
fi

if [[ $1 == "hybrid" ]]; then
	compute_hybrid_results
fi

if [[ $1 == "all" ]]; then
	compute_bimodal_results
	echo -e "\n"
	compute_gshare_results
	echo -e "\n"
	compute_yehpatt_results
	echo -e "\n"
	compute_hybrid_results
fi
