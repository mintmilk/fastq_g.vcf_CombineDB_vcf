import glob
import os
import subprocess

# 根据具体文件名编写SAMPLES的获取
raw_files = sorted(glob.glob("rawdata/*.fq.gz"))
SAMPLES = sorted(set(os.path.basename(f).split('.', 1)[0] for f in raw_files))

# 脚本路径
bash_script = "qc2gvcf.bash"
output_dir = "output"

for sample in SAMPLES:
    # 为每个样本构造 fq 文件路径
    fq1 = f"rawdata/{sample}.R1.fq.gz"
    fq2 = f"rawdata/{sample}.R2.fq.gz"

    # 检查文件是否存在
    if not os.path.exists(fq1) or not os.path.exists(fq2):
        print(f"文件不存在: {fq1} 或 {fq2}")
        continue

    # 构造命令
    command = f"sbatch --partition=XiaoYueHe --cpus-per-task=4 --mail-user=2392593414@qq.com --mail-type=ALL {bash_script} {fq1} {fq2} {sample} {output_dir}"
    print(command)
    # subprocess.run(command, shell=True) 
