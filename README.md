# snakepipes_cutadapt-HISAT2mapping-FPKM-sortBAM




```
bedtools intersect -a DetectSeq.HEK4.bed -b DigenomeSeq.HEK4.bed -loj > DetectSeq_vs_DigenomeSeq_base-on_DetectSeq_HEK4.csv

bedtools intersect -a DigenomeSeq.HEK4.bed -b DetectSeq.HEK4.bed -loj > DetectSeq_vs_DigenomeSeq_base-on_DigenomeSeq_HEK4.csv
```

check独立性，输出的追加列都是-1，说明无重叠
```
# check独立性，输出的追加列都是-1，说明无重叠
bedtools intersect -a DetectSeq_vs_DigenomeSeq_Final-DetectSeqOnly_HEK4.bed -b DetectSeq_vs_DigenomeSeq_Final-DigenomeSeqOnly_HEK4.bed -loj
```



生成random region
```
mysql --user=genome --host=genome-mysql.cse.ucsc.edu -A -e \
        "select chrom, size from hg38.chromInfo"  > hg38.genome
        
        
bedtools random -seed 20201119 -l 180 -n 100 -g hg38.genome > ./bed/random_seed-20201119_l-180_n-100_hg38.bed


cat DetectSeq_vs_DigenomeSeq_Final-DetectSeqOnly_HEK4.bed DetectSeq_vs_DigenomeSeq_Final-DetectSeqShareWithDigenomeSeq_HEK4.bed DetectSeq_vs_DigenomeSeq_Final-DigenomeSeqOnly_HEK4.bed > all_find_region.bed


bedtools intersect -a random_seed-20201119_l-180_n-200_hg38.bed -b all_find_region.bed -loj | awk -F '\t' '{if( $8==-1 ){print $1"\t"$2"\t"$3}}'| grep -v "_" >  final_random_seed-20201119_l-180_n-200_hg38.bed
########注意！check有没有带N的序列，带N的序列都不要了，到setect_region.ipyn中check 序列信息


bedtools getfasta -bed final_random_seed-20201119_l-180_n-200_hg38.bed -fi ~/zhaohn_HD/2.database/bwa_hg38/hg38_only_chromosome.fa > fasta_info_for_remove_N_bed.fa
```

然后用setect_region.ipynb筛选出only detectseq only digenomeseq和二者share的bed文件, 以及random的bed文件


接下来去生成bigwig信息关于bed region的matrix

```
computeMatrix reference-point \
-S \
../bigwig/DetectSeq_HN-HEK4-All-Input_rep1.RPKM.bw \
../bigwig/DetectSeq_HN-HEK4-All-Input_rep2.RPKM.bw \
../bigwig/DetectSeq_HN-HEK4-All-PD_rep1.RPKM.bw \
../bigwig/DetectSeq_HN-HEK4-All-PD_rep2.RPKM.bw \
../bigwig/DigenomeSeq_HEK4.RPKM.bw \
-R \
../bed/DetectSeq_vs_DigenomeSeq_Final-DetectSeqOnly_HEK4.bed \
../bed/DetectSeq_vs_DigenomeSeq_Final-DigenomeSeqOnly_HEK4.bed \
../bed/DetectSeq_vs_DigenomeSeq_Final-DetectSeqShareWithDigenomeSeq_HEK4.bed \
../bed/DetectSeq_vs_DigenomeSeq_Final-Random.bed \
-o ../RPKM.out.mat.gz \
--referencePoint center \
--beforeRegionStartLength 2000 \
--afterRegionStartLength 2000 \
--skipZeros \
--binSize 10 \
--samplesLabel \
DetectSeq_HEK4-All-Input-rep1.RPKM \
DetectSeq_HEK4-All-Input-rep2.RPKM \
DetectSeq_HEK4-All-PD-rep1.RPKM \
DetectSeq_HEK4-All-PD-rep2.RPKM \
DigenomeSeq_HEK4.RPKM \
--numberOfProcessors 10 & 
```

```
# plot coverage and heatmap
# base on region and legend on sample
plotHeatmap -m RPKM.out.mat.gz \
-out coverage.heatmap.base-on-region.pdf \
--colorList white,lightblue,purple --dpi 200 --heatmapHeight 40 --heatmapWidth 4 \
--regionsLabel Detect-seq Digenome-seq Shared Random --plotTitle "Coverage distribution of Whole genome sequencing" --perGroup --legendLocation upper-left --zMax 45
```


```
# plot coverage 
# base on sample and legend on region
plotHeatmap -m RPKM.out.mat.gz \
-out coverage.heatmap.base-on-sample.pdf \
--plotType=fill \
--colorList white,lightblue,purple --dpi 200 --heatmapHeight 13 --heatmapWidth 8 \
--regionsLabel Detect-seq Digenome-seq Shared Random --plotTitle "Coverage distribution of Whole genome sequencing" --zMax 45
```