#!/bin/bash
#SBATCH --job-name=select_filter     # 你的作业名称
#SBATCH --partition=XiaoYueHe      # 使用的分区名称
#SBATCH --nodes=1                  # 需要的节点数
#SBATCH --ntasks-per-node=1        # 每个节点的任务数
#SBATCH --cpus-per-task=2          # 每个任务的CPU核数
#SBATCH --output=select_filter.out     # 输出文件
#SBATCH --mail-user=2392593414@qq.com 
#SBATCH --mail-type=ALL

# 激活 Conda 环境
source ~/miniconda3/etc/profile.d/conda.sh
echo "conda ok"

conda activate wga
echo "activate wga"

# 启动最新JAVA
module load tools/java/v20.0.1
echo "Java-v20.0.1 ok"

export GATK_PATH="/work/apps/tools/gatk/gatk-4.4.0.0/gatk"

# 运行 Snakemake 并使用 SLURM 提交任务
mkdir -p log
snakemake -s select_filter.smk --use-conda --cores 2

echo "脚本执行完成" 