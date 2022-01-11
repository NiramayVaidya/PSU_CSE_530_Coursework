import os
import sys
import math
import matplotlib.pyplot as plt

size_dir_path = 'cache_results/size/'
associativity_dir_path = 'cache_results/associativity/'

# Saves each graph as a separate image in addition to the combinations of images
# being saved in main itself
def plot_single(x_values, y_values, point_format, legend, x_label, y_label,
        handles, labels, title, save_file):
    plt.rcParams.update({'font.size': 15})
    fig = plt.figure(figsize=(20, 14))
    subplt = fig.add_subplot(111)
    subplt.plot(x_values, y_values, point_format, label=legend)
    subplt.set_xlabel(x_label)
    subplt.set_ylabel(y_label)
    for annotation in zip(x_values, y_values):
        subplt.annotate(annotation[1], xy=annotation)
    subplt.legend(handles, labels, loc='upper left')
    plt.grid(axis='y')
    plt.title(title, fontsize=20)
    plt.savefig(save_file)
    plt.close(fig)
    plt.rcParams.update({'font.size': 10})

def main():
    if len(sys.argv) < 2:
        print("Invalid number of parameters")
        print('Usage: python3 plot_results.py <cache_size/cache_associativity>')
        sys.exit(0)
    if sys.argv[1] != 'cache_size' and sys.argv[1] != 'cache_associativity':
        print('Incorrect parameters')
        print('Usage: python3 plot_results.py <cache_size/cache_associativity>')
        sys.exit(0)
    plt.rcParams.update({'font.size': 10})
    if sys.argv[1] == 'cache_size':
        associativity = -1
        cache_sizes_metrics_mapping = {}
        for cache_config_file in os.listdir(size_dir_path):
            if cache_config_file.endswith('.cfg.out'):
                with open(size_dir_path + cache_config_file, 'r') as size_config_file:
                    metrics = size_config_file.readlines()[1].split(', ')
                    if associativity == -1:
                        associativity = int(metrics[3])
                    cache_sizes_metrics_mapping[int(metrics[1])] = (float(metrics[11]), float(metrics[8]), float(metrics[5]))
        cache_sizes = {}
        for cache_size in cache_sizes_metrics_mapping.keys():
            power = int(math.log(cache_size, 2))
            whole_value = int(power / 10)
            offset_value = int(power % 10)
            unit = ''
            if whole_value == 0:
                unit = ' B'
            elif whole_value == 1:
                unit = ' KB'
            elif whole_value == 2:
                unit = ' MB'
            elif whole_value == 3:
                unit = ' GB'
            cache_sizes[cache_size] = str(2 ** offset_value) + unit
        fig = plt.figure(figsize=(20, 14))
        fig.subplots_adjust(bottom=0.2, wspace=0.4, hspace=0.6)
        area = fig.add_subplot(131)
        area.plot([cache_sizes[key] for key in
            sorted(cache_sizes_metrics_mapping.keys())],
            [cache_sizes_metrics_mapping[key][0] for key in
            sorted(cache_sizes_metrics_mapping.keys())], 'bo-', label='Area')
        area.set_xlabel('Cache Size')
        area.set_ylabel('Area (mm^2)')
        for annotation in zip([cache_sizes[key] for key in
            sorted(cache_sizes_metrics_mapping.keys())],
            [cache_sizes_metrics_mapping[key][0] for key in
                sorted(cache_sizes_metrics_mapping.keys())]):
            area.annotate(annotation[1], xy=annotation)
        handles_temp1, labels_temp1 = area.get_legend_handles_labels()
        area.grid(axis='y')

        plot_single([cache_sizes[key] for key in
            sorted(cache_sizes_metrics_mapping.keys())],
            [cache_sizes_metrics_mapping[key][0] for key in
            sorted(cache_sizes_metrics_mapping.keys())], 'bo-', 'Area',
            'Cache Size', 'Area (mm^2)', handles_temp1, labels_temp1, 
            'Cache Associativity- ' + str(associativity),
            'graph_results/varying_cache_size_area_results.png')

        total_dynamic_read_energy_per_access = fig.add_subplot(132)
        total_dynamic_read_energy_per_access.plot([cache_sizes[key] for key in
            sorted(cache_sizes_metrics_mapping.keys())],
            [cache_sizes_metrics_mapping[key][1] for key in
            sorted(cache_sizes_metrics_mapping.keys())], 'rs-', label='Energy')
        total_dynamic_read_energy_per_access.set_xlabel('Cache Size')
        total_dynamic_read_energy_per_access.set_ylabel('Total Dynamic Read Energy Per Access (nJ)')
        for annotation in zip([cache_sizes[key] for key in
            sorted(cache_sizes_metrics_mapping.keys())],
            [cache_sizes_metrics_mapping[key][1] for key in
                sorted(cache_sizes_metrics_mapping.keys())]):
            total_dynamic_read_energy_per_access.annotate(annotation[1], xy=annotation)
        handles_temp2, labels_temp2 = total_dynamic_read_energy_per_access.get_legend_handles_labels()
        total_dynamic_read_energy_per_access.grid(axis='y')

        plot_single([cache_sizes[key] for key in
            sorted(cache_sizes_metrics_mapping.keys())],
            [cache_sizes_metrics_mapping[key][1] for key in
            sorted(cache_sizes_metrics_mapping.keys())], 'rs-', 'Energy',
            'Cache Size', 'Total Dynamic Read Energy Per Access (nJ)', 
            handles_temp2, labels_temp2, 'Cache Associativity- ' + str(associativity),
            'graph_results/varying_cache_size_energy_results.png')

        access_time = fig.add_subplot(133)
        access_time.plot([cache_sizes[key] for key in
            sorted(cache_sizes_metrics_mapping.keys())],
            [cache_sizes_metrics_mapping[key][2] for key in
            sorted(cache_sizes_metrics_mapping.keys())], 'g^-', label='Access Time')
        access_time.set_xlabel('Cache Size')
        access_time.set_ylabel('Access Time (ns)')
        for annotation in zip([cache_sizes[key] for key in
            sorted(cache_sizes_metrics_mapping.keys())],
            [cache_sizes_metrics_mapping[key][2] for key in
                sorted(cache_sizes_metrics_mapping.keys())]):
            access_time.annotate(annotation[1], xy=annotation)
        handles_temp3, labels_temp3 = access_time.get_legend_handles_labels()
        access_time.grid(axis='y')

        plot_single([cache_sizes[key] for key in
            sorted(cache_sizes_metrics_mapping.keys())],
            [cache_sizes_metrics_mapping[key][2] for key in
            sorted(cache_sizes_metrics_mapping.keys())], 'g^-', 'Access Time',
            'Cache Size', 'Access Time (ns)', handles_temp3, labels_temp3, 
            'Cache Associativity- ' + str(associativity),
            'graph_results/varying_cache_size_access_time_results.png')

        handles = handles_temp1 + handles_temp2 + handles_temp3
        labels = labels_temp1 + labels_temp2 + labels_temp3
        fig.legend(handles, labels, loc='lower center')
        fig.suptitle('Cache Associativity- ' + str(associativity))
        plt.savefig('graph_results/varying_cache_size_results.png')
        plt.show()
        plt.close(fig)
    else:
        size = 0
        cache_associativities_metrics_mapping = {}
        for cache_config_file in os.listdir(associativity_dir_path):
            if cache_config_file.endswith('.cfg.out'):
                with open(associativity_dir_path + cache_config_file, 'r') as associativity_config_file:
                    metrics = associativity_config_file.readlines()[1].split(', ')
                    if size == 0:
                        size = int(metrics[1])
                    cache_associativities_metrics_mapping[metrics[3]] = (float(metrics[11]), float(metrics[8]), float(metrics[5]))
        power = int(math.log(size, 2))
        whole_value = int(power / 10)
        offset_value = int(power % 10)
        unit = ''
        if whole_value == 0:
            unit = ' B'
        elif whole_value == 1:
            unit = ' KB'
        elif whole_value == 2:
            unit = ' MB'
        elif whole_value == 3:
            unit = ' GB'
        size = str(2 ** offset_value) + unit
        fig = plt.figure(figsize=(20, 14))
        fig.subplots_adjust(bottom=0.2, wspace=0.4, hspace=0.6)
        area = fig.add_subplot(131)
        area.plot(sorted(cache_associativities_metrics_mapping.keys(), key=int),
            [cache_associativities_metrics_mapping[key][0] for key in
            sorted(cache_associativities_metrics_mapping.keys(), key=int)], 'bo-', label='Area')
        area.set_xlabel('Cache Associativity')
        area.set_ylabel('Area (mm^2)')
        for annotation in zip(sorted(cache_associativities_metrics_mapping.keys(), key=int),
            [cache_associativities_metrics_mapping[key][0] for key in
                sorted(cache_associativities_metrics_mapping.keys(), key=int)]):
            area.annotate(annotation[1], xy=annotation, rotation=(90))
        handles_temp1, labels_temp1 = area.get_legend_handles_labels()
        area.grid(axis='y')

        plot_single(sorted(cache_associativities_metrics_mapping.keys(),
            key=int), [cache_associativities_metrics_mapping[key][0] for key in
            sorted(cache_associativities_metrics_mapping.keys(), key=int)],
            'bo-', 'Area', 'Cache Associativity', 'Area (mm^2)', handles_temp1,
            labels_temp1, 'Cache Size- ' + size,
            'graph_results/varying_cache_associativity_area_results.png')

        total_dynamic_read_energy_per_access = fig.add_subplot(132)
        total_dynamic_read_energy_per_access.plot(
            sorted(cache_associativities_metrics_mapping.keys(), key=int),
            [cache_associativities_metrics_mapping[key][1] for key in
            sorted(cache_associativities_metrics_mapping.keys(), key=int)], 'rs-', label='Energy')
        total_dynamic_read_energy_per_access.set_xlabel('Cache Associativity')
        total_dynamic_read_energy_per_access.set_ylabel('Total Dynamic Read Energy Per Access (nJ)')
        for annotation in zip(sorted(cache_associativities_metrics_mapping.keys(), key=int),
            [cache_associativities_metrics_mapping[key][1] for key in
                sorted(cache_associativities_metrics_mapping.keys(), key=int)]):
            total_dynamic_read_energy_per_access.annotate(annotation[1], xy=annotation, rotation=(90))
        handles_temp2, labels_temp2 = total_dynamic_read_energy_per_access.get_legend_handles_labels()
        total_dynamic_read_energy_per_access.grid(axis='y')

        plot_single(sorted(cache_associativities_metrics_mapping.keys(),
            key=int), [cache_associativities_metrics_mapping[key][1] for key in
            sorted(cache_associativities_metrics_mapping.keys(), key=int)],
            'rs-', 'Energy', 'Cache Associativity', 
            'Total Dynamic Read Energy Per Access (nJ)', handles_temp2,
            labels_temp2, 'Cache Size- ' + size,
            'graph_results/varying_cache_associativity_energy_results.png')

        access_time = fig.add_subplot(133)
        access_time.plot(sorted(cache_associativities_metrics_mapping.keys(), key=int),
            [cache_associativities_metrics_mapping[key][2] for key in
            sorted(cache_associativities_metrics_mapping.keys(), key=int)], 'g^-', label='Access Time')
        access_time.set_xlabel('Cache Associativity')
        access_time.set_ylabel('Access Time (ns)')
        for annotation in zip(sorted(cache_associativities_metrics_mapping.keys(), key=int),
            [cache_associativities_metrics_mapping[key][2] for key in
                sorted(cache_associativities_metrics_mapping.keys(), key=int)]):
            access_time.annotate(annotation[1], xy=annotation, rotation=(90))
        handles_temp3, labels_temp3 = access_time.get_legend_handles_labels()
        access_time.grid(axis='y')

        plot_single(sorted(cache_associativities_metrics_mapping.keys(),
            key=int), [cache_associativities_metrics_mapping[key][2] for key in
            sorted(cache_associativities_metrics_mapping.keys(), key=int)],
            'g^-', 'Access Time', 'Cache Associativity', 'Access Time (ns)', 
            handles_temp3, labels_temp3, 'Cache Size- ' + size,
            'graph_results/varying_cache_associativity_access_time_results.png')

        handles = handles_temp1 + handles_temp2 + handles_temp3
        labels = labels_temp1 + labels_temp2 + labels_temp3
        fig.legend(handles, labels, loc='lower center')
        fig.suptitle('Cache Size- ' + size)
        plt.savefig('graph_results/varying_cache_associativity_results.png')
        plt.show()
        plt.close(fig)

if __name__ == '__main__':
    main()
