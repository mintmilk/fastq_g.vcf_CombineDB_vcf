#!/bin/bash

source ~/miniconda3/etc/profile.d/conda.sh
echo "conda ok"

conda activate wga
echo "activate wga"

module load tools/java/v20.0.1
echo "Java-v20.0.1 ok"

gatk="/work/apps/tools/gatk/gatk-4.4.0.0/gatk"

reference="index/GCF_000002315.6_GRCg6a_genomic.fna"

fq1=$1
fq2=$2
sample=$3
outdir=$4

outdir=${outdir}/${sample}


fq_file_name=`basename $fq1`
fq_file_name=${fq1_file_name%%_1.fq.gz}


if [ ! -d $outdir/cleanfq ]
then mkdir -p $outdir/cleanfq
fi

if [ ! -d $outdir/bwa ]
then mkdir -p $outdir/bwa
fi

if [ ! -d $outdir/gatk ]
then mkdir -p $outdir/gatk
fi

time fastp -i $fq1 -o $outdir/cleanfq/${sample}.paired.1.fq.gz -I $fq2 -O $outdir/cleanfq/${sample}.paired.2.fq.gz -j $outdir/cleanfq/${sample}.json -h $outdir/cleanfq/${sample}.html -w 4 --length_required=50 --n_base_limit=6 --compression=6 && echo "** fq QC done **"

time bwa mem -t 4 -M -Y -R "@RG\tID:foo_lane\tPL:ILLUMINA\tLB:library\tSM:$sample" $reference $outdir/cleanfq/${sample}.paired.1.fq.gz $outdir/cleanfq/${sample}.paired.2.fq.gz | $samtools view -Sb - > $outdir/bwa/${sample}.bam && echo "** BWA MEM done **" 

time samtools sort -@ 4 -m 4G -O bam -o $outdir/bwa/${sample}.sorted.bam $outdir/bwa/${sample}.bam && echo "** sorted raw bamfile done **"

time $gatk MarkDuplicates -I $outdir/bwa/${sample}.sorted.bam -M $outdir/bwa/${sample}.markdup_metrics.txt -O $outdir/bwa/${sample}.sorted.markdup.bam --VALIDATION_STRINGENCY LENIENT --MAX_FILE_HANDLES_FOR_READ_ENDS_MAP 1000 && echo "** ${sample}.markdup.bam done **"

time samtools index $outdir/bwa/${sample}.sorted.markdup.bam && echo "** ${sample}.sorted.markdup.bam index done **"

time $gatk --java-options "-Xmx32G -Djava.io.tmpdir=./" HaplotypeCaller --emit-ref-confidence GVCF -R $reference -I $outdir/bwa/${sample}.sorted.markdup.bam -O $outdir/gatk/${sample}.HC.g.vcf.gz && echo "** GVCF done **"
