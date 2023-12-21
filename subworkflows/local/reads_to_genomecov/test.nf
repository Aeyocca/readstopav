//
// Subworkflow for bwa_mem2, samtools sort, then bedtools genomecov
//

/*
========================================================================================
    IMPORT MODULES/SUBWORKFLOWS
========================================================================================
*/

nextflow.enable.dsl = 2

include { BWAMEM2_ALIGNER                } from '../reads_to_genomecov'
include { GENOMECOV                      } from '../reads_to_genomecov'


params.raw = "test/*{1,2}.fastq.gz"
reads_ch = Channel.fromFilePairs(params.raw, checkIfExists: true )
genome = "test/Athal_chr1.fasta"
genome_fai = "test/Athal_chr1.fasta.fai"
scale = 1
def meta = [:]
meta.id = "read"

workflow {
    BWAMEM2_ALIGNER(reads_ch, genome)
    GENOMECOV(meta, BWAMEM2_ALIGNER.out.bam, scale)
}
