# ------------------------------------------------------------------->>>>>>>>>>
# step 1
#     generate random region
# ------------------------------------------------------------------->>>>>>>>>>
# get hg38 genome size
mysql \
	--user=genome \
	--host=genome-mysql.cse.ucsc.edu \
	-A \
	-e "select chrom, size from hg38.chromInfo" \
	> hg38.genome

# ------------------------------------------------------------------->>>>>>>>>>
# step 1
#     generate random region

# -l	The length of the intervals to generate.
#		- Default = 100.
# ------------------------------------------------------------------->>>>>>>>>>
# generate random bed
bedtools random -seed 20221023 \
	-l 180 \
	-n 100 \
	-g hg38.genome \
	> random_l-180_n-100_hg38.bed

# get all region to test
cp ../bed/ENCFF285QVL_CTCF_binding_sites_fix_range.bed all_find_region.bed 

# 去掉random region中偶然落在需要 test 的 region 中的 region
bedtools intersect \
	-a random_l-180_n-100_hg38.bed \
	-b all_find_region.bed -loj | \
	awk -F '\t' '{if( $8==-1 ){print $1"\t"$2"\t"$3}}'| \
	grep -v "_" > random_l-180_n-100_hg38_minus-test.bed

########注意！check有没有带N的序列，带N的序列都不要了，到setect_region.ipyn中check 序列信息
bedtools getfasta \
	-bed random_l-180_n-100_hg38_minus-test.bed \
	-fi ~/Bio/1.database/db_genomes/genome_fa/genome_ucsc_hg38/genome_ucsc_hg38.fa \
	> random_l-180_n-100_hg38_minus-test.fa

bioat_fastatools filter_n \
	-i random_l-180_n-100_hg38_minus-test.fa |\
	grep ">" |\
	awk '{sub(/>/,""); sub(/:/, "\t"); sub(/-/, "\t"); print $0}' |\
	bedtools sort |\
	> random_l-180_n-100_hg38_final.bed


computeMatrix reference-point \
-S \
../bigwig/DetectSeq_ATP8-DddAwt_REP-1_final_rmdup.RPKM.bw \
../bigwig/DetectSeq_ATP8-DddA6_REP-1_final_rmdup.RPKM.bw \
../bigwig/DetectSeq_ATP8-DddA11_REP-1_final_rmdup.RPKM.bw \
../bigwig/DetectSeq_JAK2-DddA11_REP-1_final_rmdup.RPKM.bw \
../bigwig/DetectSeq_SIRT6-DddA11_REP-1_final_rmdup.RPKM.bw \
../bigwig/293T-DdCBE-ND5.1-All-PD_rep2_hg38.MAPQ20.RPKM.bw \
../bigwig/293T-DdCBE-ND6-All-PD_rep2_hg38.MAPQ20.RPKM.bw \
../bigwig/Vector-merge_hg38_merge_sort_rmdup.MAPQ20.RPKM.bw \
-R \
../bed/ENCFF285QVL_CTCF_binding_sites_fix_range.bed  \
../bed/ctcf_low.bed \
../bed/ctcf_middle.bed \
../bed/ctcf_high.bed \
-o ../RPKM.out.mat.gz \
--referencePoint center \
--beforeRegionStartLength 2000 \
--afterRegionStartLength 2000 \
--skipZeros \
--binSize 10 \
--samplesLabel \
ATP8-DddAwt_REP-1 \
ATP8-DddA6_REP-1 \
ATP8-DddA11_REP-1 \
JAK2-DddA11_REP-1 \
SIRT6-DddA11_REP-1 \
293T-DdCBE-ND5.1-All-PD_rep2 \
293T-DdCBE-ND6-All-PD_rep2 \
Vector


