#!/bin/bash
#SBATCH --job-name=2CombDB
#SBATCH --partition=YongDingHe  
#SBATCH --nodes=1 
#SBATCH --cpus-per-task=64            
#SBATCH --output=Comb_%j.log
#SBATCH --mail-user=2392593414@qq.com 
#SBATCH --mail-type=ALL

source /work/home/zhgroup02/miniconda3/bin/activate

conda activate wga
echo "conda enter wga"

export GATK="/work/apps/tools/gatk/gatk-4.4.0.0/gatk"

# 启动最新JAVA
module load tools/java/v20.0.1
java_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
if [[ "$java_version" != "20.0.1" ]]; then
    echo "Error loading Java version 20.0.1. Current version is $java_version."
    exit 1
else
    echo "Java-v20.0.1 ok"
fi

python3 CombineDB2.py > CombineDBpy.out 2>CombineDBpy.err

# 在脚本执行完成后发送通知
echo "脚本执行完成" 
curl https://api.day.app/EFoykKEWiQMTNRq7wscPQZ/合并完成