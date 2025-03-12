rule deepvariant:
    input:
        ref = '/GRCh38_full_analysis_set_plus_decoy_hla.fa', 
        reads = '/{sample}.dedup.bam'
    output:
        vcf = '/deepvariant/{sample}_dv.vcf.gz',
        gvcf = '/deepvariant/{sample}_dv.g.vcf.gz'
    params:
        threads = 4
    shell:
        "singularity run --bind working_directory/:/mnt --nv docker://google/deepvariant:'1.4.0-gpu' deepvariant/run_deepvariant --model_type=WGS --ref={input.ref} --reads={input.reads} --output_vcf={output.vcf} --output_gvcf={output.gvcf} --num_shards={params.threads}"

rule annotate_variants:
    input:
        calls="{samples}.vcf.gz",
        cache="/vep/resources/cache",
        plugins="/vep/resources/plugins"
    output:
        calls="/vep/{samples}_annotated.vcf.gz",
        stats="/vep/{samples}_annotated.html"
    params:
        plugins=["CADD","ClinPred","GWAS","LoFtool","pLI"]
    log: 
        "/vep/{samples}_annotate.log",
    threads: 4
    wrapper:
        "v2.2.1/bio/vep/annotate"  
