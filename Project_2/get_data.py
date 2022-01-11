import sys

def main():
    data = []
    with open(sys.argv[1], 'r') as compute_report:
        lines = compute_report.readlines()
        for i in range(1, len(lines)):
            line = lines[i].split(', ')
            data.append((int(line[0]), int(line[1]), round(float(line[3]), 2)))
    with open(sys.argv[2], 'w') as data_file:
        data_file.write('Layer\tCompute_Cycles\tOverall_Utilization\n')
        for d in data:
            data_file.write(str(d[0]) + '\t' + str(d[1]) + '\t' + str(d[2]) + '\n')

if __name__ == '__main__':
    main()
