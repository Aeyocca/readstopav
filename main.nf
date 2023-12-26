#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*
========================================================================================
    IMPORT MODULES/SUBWORKFLOWS
========================================================================================
*/

include { FETCHNGS     } from './subworkflows/nf-core/fetchngs'
include { BWAMEM2_INDEX } from './modules/nf-core/bwamem2/index/main'
include { BWAMEM2_MEM } from './modules/nf-core/bwamem2/mem/main'
include { BEDTOOLS_GENOMECOV } from './modules/nf-core/bedtools/genomecov/main'

// reads_ch = Channel
//    .fromFilePairs("test/*{1,2}.fastq.gz")
def dummy_meta = []
genome = file( "test/Athal_chr1.fasta" )
sizes = Channel.fromPath("test/Athal_chr1.fasta.fai")
extension = "genomecov"


workflow {
    FETCHNGS()
    
    BWAMEM2_INDEX( meta : dummy_meta, fasta : genome )
    // //  BWAMEM2_ALIGNER(read_ch, genome)
    sort_bam = true
    
    // subworkflow or just a process to create the reads_ch
    
    read_one_ch = Channel.fromFilePairs(params.outdir + "/fastq/" + 
        FETCHNGS.out.ids + "*{1,2}.fastq.gz")
        .view()
    
    BWAMEM2_MEM( read_one_ch , BWAMEM2_INDEX.out.index, sort_bam )
    
    BWAMEM2_MEM.out.bam.view { path -> file('output.bam', path) }
    
    BEDTOOLS_GENOMECOV(BWAMEM2_MEM.out.bam, sizes, extension)
    
}

