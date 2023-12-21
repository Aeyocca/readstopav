//
// Subworkflow for bwa_mem2, samtools sort, then bedtools genomecov
//

/*
========================================================================================
    IMPORT MODULES/SUBWORKFLOWS
========================================================================================
*/

include { BWAMEM2_INDEX } from '../../modules/nf-core/modules/bwamem2/index/main'
include { BWAMEM2_MEM } from '../../modules/nf-core/modules/bwamem2/mem/main'

workflow BWAMEM2_ALIGNER {
    input:
    reads            // channel: [ val(meta), [ reads ] ]
    genome          // channel: file(ref_genome)

    main:

    ch_versions = Channel.empty()

    //
    // index the genome with bwamem2 index
    //
    BWAMEM2_INDEX ( genome )
    ch_versions = ch_versions.mix(BWAMEM2_INDEX.out.versions)

    //
    // Map reads with bwamem2 mem
    //
    sort_bam = true
    BWAMEM2_MEM ( reads, BWAMEM2_INDEX.out.index, sort_bam )
    ch_versions = ch_versions.mix(BWAMEM2_MEM.out.versions)

    emit:
    bam            = BWAMEM2_MEM.out.bam  // channel: [ val(meta), [ bam ] ]
    versions       = ch_versions          // channel: [ versions.yml ]
}

workflow GENOMECOV {
    input:
    bam
    genome_fai
    
    main:
    
    BEDTOOLS_GENOMECOV(bam)
    
    
    emit:
    bed
}

params.raw = "test/*{1,2}.fastq.gz"
reads_ch = Channel.fromFilePairs(params.raw, checkIfExists: true )
genome = "test/Athal_chr1.fasta"
genome = "test/Athal_chr1.fasta.fai"

workflow {
    BWAMEM2_ALIGNER(reads_ch, genome)
    GENOMECOV(BWAMEM2_ALIGNER.out.bam, genome_fai)
}