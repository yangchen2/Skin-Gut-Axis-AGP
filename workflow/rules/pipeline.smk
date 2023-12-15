import os
import biom

# Define your partitions
partitions = ["skin_and_gut_disease_pos", "skin_pos_and_gut_disease_neg", "skin_neg_and_gut_disease_pos", "skin_and_gut_disease_neg"]

# Define a rule for each partition
rule filter_duplicate_samples:
    input:
        biom_table="../data_download/tables/{partition}.biom",
        metadata="../data_download/metadata/{partition}_metadata.tsv"
    output:
        biom_table_filtered="output/filtered_tables/{partition}_filtered.biom",
        metadata_filtered="output/filtered_metadata/{partition}_filtered.tsv"
    params:
        script="scripts/filter_duplicate_samples.py"
    # log: 
    #     "workflow/log/{partition}/filter_duplicate_samples.log"
    shell:
        "python {params.script} {input.biom_table} {input.metadata} {output.biom_table_filtered} {output.metadata_filtered} {wildcards.partition}"

all_tables = expand(
    "output/filtered_tables/{partition}_filtered.biom",
    partition=partitions
)

all_metadata = expand(
    "output/filtered_metadata/{partition}_filtered.tsv",
    partition=partitions
)