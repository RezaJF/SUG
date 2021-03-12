#!/bin/bash
#$ -j y
#$ -S /bin/bash
#$ -cwd
# Job name
#$ -N WES_VCF_merge_bottomQ
# Number of cpu cores required
#$ -pe smp 1
# RAM requirement per cpu core
#$ -l h_vmem=64G

module load GenomeAnalysisTK/4.1.2.0/java.1.8.0_20
module load bcftools
module load tabix

if [ $# -ne 1 ]
then
    echo "Usage: `basename $0` PATH_to_REF_hg38"
    exit 1
fi


PATH_to_REF_hg38=$1

cat subSample.txt | while read i j
	do
		samples=$(cat bottom_cPRS_quintile_centenarian.txt | while read i; do find /home/zdzlab/common/U19/data/Einstein-Centenarians/REGN_Freeze_One/data/GVCF/ | grep -E '.gvcf.gz$' | grep -v DUPLICATE.gvcf.gz | sed 's/^/--variant /' | grep $i; done)


		gatk CombineGVCFs \
			-R $PATH_to_REF_hg38 \
			-O ${j}.g.vcf.gz \
			$(echo $samples)

		gatk GenotypeGVCFs \
			-R $PATH_to_REF_hg38 \
			-V ${j}.g.vcf.gz \
			-O ${j}.vcf \
			--allow-old-rms-mapping-quality-annotation-data

		bgzip ${j}.vcf
		bcftools index ${j}.vcf.gz

		mkdir $j && mv ${j}.vcf.gz* $j

		rm ${j}.g.vcf.gz


	done


head -5 subSample.txt | while read i j

	do
		bcftools isec \
			/non-95PLUS/non-95PLUS.vcf.gz \
			/${j}/${j}.vcf.gz \
			-p /${j}

done			




