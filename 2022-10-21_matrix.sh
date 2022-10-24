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

# generate random bed
bedtools random -seed 20221023 \
	-l 200 \
	-n 10000 \
	-g hg38.genome \
	> random_hg38.bed
	# -l	The length of the intervals to generate.

# get all region to test
cp ../bed/ENCFF285QVL_CTCF_binding_sites_fix_range.bed all_find_region.bed 

# 去掉random region中偶然落在需要 test 的 region 中的 region
bedtools intersect \
	-a random_hg38.bed \
	-b all_find_region.bed -loj | \
	awk -F '\t' '{if( $8==-1 ){print $1"\t"$2"\t"$3}}'| \
	grep -v "_" > random_hg38_minus-test.bed

########注意！check有没有带N的序列，带N的序列都不要了，到setect_region.ipyn中check 序列信息
bedtools getfasta \
	-bed random_hg38_minus-test.bed \
	-fi ~/Bio/1.database/db_genomes/genome_fa/genome_ucsc_hg38/genome_ucsc_hg38.fa \
	> random_hg38_minus-test.fa

bioat_fastatools filter_n \
	-i random_hg38_minus-test.fa |\
	grep ">" |\
	awk '{sub(/>/,""); sub(/:/, "\t"); sub(/-/, "\t"); print $0}' |\
	bedtools sort |\
	> random_hg38_final.bed

# clean temp file
rm random_hg38.bed random_hg38_minus-test.bed random_hg38_minus-test.fa


# ------------------------------------------------------------------->>>>>>>>>>
# step 2
#     generate matrix
# ------------------------------------------------------------------->>>>>>>>>>


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
random_hg38_final.bed \
-o ../RPKM.out.mat.gz \
--referencePoint center \
--beforeRegionStartLength 2000 \
--afterRegionStartLength 2000 \
--skipZeros \
--binSize 50 \
--samplesLabel \
ATP8-DddAwt-1 \
ATP8-DddA6-1 \
ATP8-DddA11-1 \
JAK2-DddA11-1 \
SIRT6-DddA11-1 \
ND5.1-DddAwt-2 \
ND6-DddAwt-2 \
Vector


# ------------------------------------------------------------------->>>>>>>>>>
# step 3
#     plot heatmap
# ------------------------------------------------------------------->>>>>>>>>>
# plot coverage and heatmap
# base on region and legend on sample
plotHeatmap -m ../RPKM.out.mat.gz \
	-out coverage.heatmap.base-on-region.pdf \
	--colorList white,lightblue,purple \
	--dpi 200 --heatmapHeight 40 --heatmapWidth 4 \
	--regionsLabel CTCF-all CTCF-low CTCF-middle CTCF-high Random \
	--plotTitle "Coverage distribution of Whole genome sequencing" \
	--perGroup \
	--legendLocation upper-left
	# --zMax 45

# plot coverage 
# base on sample and legend on region
plotHeatmap -m ../RPKM.out.mat.gz \
	-out coverage.heatmap.base-on-sample.pdf \
	--plotType=fill \
	--colorList white,lightblue,purple \
	--dpi 200 --heatmapHeight 13 --heatmapWidth 8 \
	--regionsLabel CTCF-all CTCF-low CTCF-middle CTCF-high Random \
	--plotTitle "Coverage distribution of Whole genome sequencing"
	# --zMax 45

