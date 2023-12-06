# fastq_g.vcf_CombineDB_vcf
For the preparation of population genome data analysis, the genome sequencing data are subjected to quality control, sequencing, comparison, CallSNP, and the CombineDB form is used to merge the gvcf files to generate the population vcf files, which are prepared for the subsequent analysis.
# 环境配置
gatk使用管理员预安装的版本，在qc2gvcf.bash中配置了软件位置；其他软件都采用conda。
# 文件结构
'''
├───output
│   └───sample1
│       ├───bwa
│       ├───fastp
│       └───gatk
└───rawdata
'''
# 使用说明
配置好sample获取代码和环境配置部分后，运行new_gvcf.py，并行提交slurm作业对每个样本进行CallSNP，生成g.vcf。检查运行情况后，通过运行CombineDB2.sh提交slurm作业运行。
