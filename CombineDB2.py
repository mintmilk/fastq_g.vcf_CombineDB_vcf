import os
from multiprocessing import Pool

# ========== VARIABLES ==========
BASE_DIR = os.path.expanduser("gatk")
REFERENCE_GENOME = "index/GCF_000002315.6_GRCg6a_genomic.fna"
FAI_FILE = "index/GCF_000002315.6_GRCg6a_genomic.fna.fai"
INTERVAL_SIZE = 1000000
POOL_SIZE =32
GENOMICSDB_THREADS =32
FINAL_OUTPUT_VCF = "final_output.vcf"
# ===============================

def find_gvcfs(base_dir):
    gvcf_files = []
    for root, dirs, files in os.walk(base_dir):
        for file in files:
            if file.endswith(".HC.g.vcf.gz"):
                gvcf_files.append(os.path.join(root, file))
    return gvcf_files

def generate_intervals(fai_file, interval_size=INTERVAL_SIZE):
    intervals = []
    with open(fai_file, 'r') as f:
        for line in f:
            parts = line.strip().split("\t")
            chrom = parts[0]
            chrom_length = int(parts[1])
            for start in range(1, chrom_length + 1, interval_size): 
                end = min(chrom_length, start + interval_size - 1) 
                intervals.append(f"{chrom}:{start}-{end}")
    return intervals

def process_interval(args):
    interval, gvcf_files = args
    db_path = f"genomicsdb_{interval.replace(':', '_').replace('-', '_')}"
    output_vcf = f"part_{interval.replace(':', '_').replace('-', '_')}.vcf"
    
    # 检查GenomicsDB工作空间是否已存在
    if not os.path.exists(db_path):
        genomicsdb_import(gvcf_files, interval, db_path)
    else:
        print(f"GenomicsDB workspace {db_path} already exists. Skipping...")

    # 检查part VCF是否已存在
    if not os.path.exists(output_vcf):
        genotype_gvcfs(db_path, interval, output_vcf)
    else:
        print(f"Output VCF {output_vcf} already exists. Skipping...")
    
    return output_vcf

def genomicsdb_import(gvcf_files, interval, db_path):
    cmd = ["$GATK GenomicsDBImport", f"--reader-threads {GENOMICSDB_THREADS}"]
    for gvcf_file in gvcf_files:
        cmd.append(f"-V {gvcf_file}")
    cmd.append(f"--genomicsdb-workspace-path {db_path}")
    cmd.append(f"--intervals {interval}")
    if os.system(' '.join(cmd)) != 0:
        print(f"Error with GenomicsDBImport for interval {interval}")
        exit(1)

def genotype_gvcfs(db_path, interval, output_vcf):
    cmd = f"$GATK GenotypeGVCFs -R {REFERENCE_GENOME} -V gendb://{db_path} -O {output_vcf} --intervals {interval}"
    if os.system(cmd) != 0:
        print(f"Error with GenotypeGVCFs for interval {interval}")
        exit(1)

def gather_vcfs(vcfs, final_output):
    cmd = ["$GATK GatherVcfs"]
    for vcf in vcfs:
        cmd.append(f"-I {vcf}")
    cmd.append(f"-O {final_output}")
    if os.system(' '.join(cmd)) != 0:
        print(f"Error with GatherVcfs")
        exit(1)

def main():
    gvcf_files = find_gvcfs(BASE_DIR)
    if not gvcf_files:
        print("No GVCF files found!")
        exit(1)

    print("Generating intervals...")
    intervals = generate_intervals(FAI_FILE)

    print("Processing intervals...")
    with Pool(POOL_SIZE) as pool:
        intermediate_vcfs = pool.map(process_interval, [(interval, gvcf_files) for interval in intervals])

    print("Gathering VCFs...")
    gather_vcfs(intermediate_vcfs, FINAL_OUTPUT_VCF)
    print("Done!")

if __name__ == "__main__":
    main()
