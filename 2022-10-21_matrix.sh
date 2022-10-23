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