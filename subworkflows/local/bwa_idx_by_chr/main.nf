#!/usr/bin/env nextflow

include { BWAMEM2_INDEX      } from '../../../modules/nf-core/bwamem2/index/main'

process SPLIT_FASTA {
    input:
    tuple val(chr), val(genome_ch)
    
    output:
    tuple val(chr), path("split_genome/*"), emit: split_genome

    script:
    chr_string = chr.replaceAll(/\[/, "").replaceAll(/\]/, "")
    output = genome_ch.genome.baseName + "_" + chr_string
    
    """
    
    mkdir split_genome
    
    subset_fa.pl \\
    -f ${genome_ch.genome} \\
    -s ${chr_string} \\
    -o split_genome/${output}
    
    """
}


workflow BWA_IDX_BY_CHR {

    take:
    genome_ch
    chrom_ch

    main:
    ch_versions = Channel.empty()
    
    // need to combine chrom and genome channels to properly parallelize, yes?
    chrom_ch.combine(genome_ch)
        .set{split_ch}
    
    // split_ch.view()
    
    SPLIT_FASTA(split_ch)
    
    // tuple val(meta), path(fasta)
    
    // SPLIT_FASTA.out.split_genome.view()
    
    BWAMEM2_INDEX(SPLIT_FASTA.out.split_genome)
    
    // split genome by chromosome and index each
    
    // BWAMEM2_INDEX.out.index.view()
    
    emit:
    idx_out = BWAMEM2_INDEX.out.index
    // chr_out = chrom_ch
    
}