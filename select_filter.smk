
GATK_PATH = os.environ.get('GATK_PATH', '/work/apps/tools/gatk/gatk-4.4.0.0/gatk')
GENOME ="/work/home/zhgroup02/TBCM/clean/index/GCF_000002315.6_GRCg6a_genomic.fna"

rule all:
    input:
        "combine3_SNP.filtered.vcf.gz"

# 筛选SNP、INDEL等
rule select_SNP:
    input:
        vcf="final_output.vcf",
        ref=GENOME,
    output:
        "combine_SNP.raw.vcf"
    shell:
        """
        {GATK_PATH} SelectVariants -R {input.ref} -O {output} --variant {input.vcf} --select-type-to-include SNP
        echo "** selectSNP done **"
        """

rule filter_SNP:
    input:
        ref=GENOME,
        variant="combine_SNP.raw.vcf"
    output:
        "combine_SNP.filtered.vcf"
    shell:
        """
        {GATK_PATH} VariantFiltration -R {input.ref} -O {output} --variant {input.variant} --filter-name "snp_filter" --filter-expression "QD < 2.0 || FS > 60.0 || SOR > 3.0 || MQ < 40.0 || MQRankSum < -12.5"
        echo "** SNP filter done **"
        """

rule bgzipvcf:
    input:
        vcf_file="combine_SNP.filtered.vcf"
    output:
        bgzipped_vcf="combine3_SNP.filtered.vcf.gz"
    shell:
        """
        bgzip -c {input.vcf_file} > {output.bgzipped_vcf}
        """
