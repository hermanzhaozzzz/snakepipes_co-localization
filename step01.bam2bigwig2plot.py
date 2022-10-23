THREAD = 10

BAM_COVERAGE = 'bamCoverage'
COMPUTE_MATRIX = 'computeMatrix'
PLOT_HEATMAP = 'plotHeatmap'


SAMPLE = [
	'293T-DdCBE-ND5.1-All-PD_rep2_hg38.MAPQ20',
	'293T-DdCBE-ND6-All-PD_rep2_hg38.MAPQ20',
	'293T-GFP-PD_rep1_hg38.MAPQ20',
	'DetectSeq_ATP8-DddA11_REP-1_final_rmdup',
	'DetectSeq_ATP8-DddA6_REP-1_final_rmdup',
	'DetectSeq_ATP8-DddAwt_REP-1_final_rmdup',
	'DetectSeq_JAK2-DddA11_REP-1_final_rmdup',
	'DetectSeq_SIRT6-DddA11_REP-1_final_rmdup',
	'Vector-merge_hg38_merge_sort_rmdup.MAPQ20',
]


rule all:
    input:
        expand("../bam/{sample}.bam", sample=SAMPLE),
        expand("../bigwig/{sample}.RPKM.bw", sample=SAMPLE)
# step 1: DetectSeq bam to bigwig RPKM (not CPM)
rule bam2bigwig_RPKM:
    input:
        "../bam/{sample}.bam"
    output:
        "../bigwig/{sample}.RPKM.bw"
    shell:
        """
        {BAM_COVERAGE} \
        	--bam {input} \
        	-o {output} \
        	-of bigwig \
        	--scaleFactor 1 \
        	--binSize 10 \
        	-p {THREAD} --normalizeUsing RPKM
        """