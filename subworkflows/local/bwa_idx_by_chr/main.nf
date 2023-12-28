#!/usr/bin/env nextflow

include { BWAMEM2_INDEX      } from '../../../modules/nf-core/bwamem2/index/main'

process SPLIT_FASTA {
    input:
    val(chr)

    output:
    path(output)

    script:
    // output = chr[0].ref_genome.replaceFirst(/\.fasta/,"_${chr}.fasta")
    // chr_string = chr[1].replaceAll(/[/, "").replaceAll(/]/, "")
    
    output = chr[0].ref_genome
    // clean_genome = output.replaceFirst(/\.fasta/,"_${chr}.fasta")
    chr_string = chr[1]
    """
    
    echo ${output}
    echo ${chr_string}
    split_fa.pl -f chr[0].ref_genome -s ${chr_string} -o ${output}
    
    """
}


workflow BWA_IDX_BY_CHR {

    take:
    index_input
    chrom_ch

    main:
    ch_versions = Channel.empty()
    
    chr_idx = index_input.combine(chrom_ch)
    
    SPLIT_FASTA(chr_idx)
    
    BWAMEM2_INDEX(SPLIT_FASTA.output)
    
    // split genome by chromosome and index each

    emit:
    chr_out = BWAMEM2_INDEX.out.index
    
}