import os
import sys
import pandas as pd
import biom
from biom.util import biom_open
from biom import Table
import logging

def setup_logging(partition):
    log_directory = f"workflow/log/{partition}"
    os.makedirs(log_directory, exist_ok=True)
    logging.basicConfig(filename=f"{log_directory}/filter_duplicate_samples.log",
                        level=logging.INFO,
                        format='%(asctime)s - %(levelname)s - %(message)s',
                        datefmt='%Y-%m-%d %H:%M:%S')
    return logging.getLogger()

def filter_datasets(biom_table, metadata, biom_output_file, metadata_output_file, logger):
    try:
        # Load biom table
        with biom_open(biom_table) as f:
            biom_table = Table.from_hdf5(f)

        # Load metadata 
        metadata = pd.read_csv(metadata, sep='\t').set_index('#SampleID')

        # Drop duplicate samples from same individuals in the metadata df
        logging.info(f'Starting number of samples: {metadata.shape[0]}')
        metadata_filtered = metadata.drop_duplicates(subset='host_subject_id', keep='first')
        logging.info(f'Number of samples after dropping duplicates: {metadata_filtered.shape[0]}')

        # Save filtered metadata
        metadata_filtered.to_csv(metadata_output_file, sep='\t', index=False)

        # Subset the biom table based on the filtered metadata
        biom_df = biom_table.to_dataframe().transpose()
        biom_df_filtered = biom_df.loc[metadata_filtered.index]

        # Convert the DataFrame to a BIOM table
        obs_ids = biom_df_filtered.index
        samp_ids = biom_df_filtered.columns
        table = biom.table.Table(biom_df_filtered.values, observation_ids=obs_ids, sample_ids=samp_ids)
        
        # Save the BIOM table
        with biom_open(biom_output_file, 'w') as f:
            table.to_hdf5(f, generated_by="filtered table")
    except Exception as e:
        logger.exception("An error occurred during processing")

if __name__ == "__main__":
    if len(sys.argv) != 6:
        print("Usage: python filter_samples.py <biom_table> <metadata> <biom_output_file> <metadata_output_file> <partition>")
        sys.exit(1)

    biom_table, metadata, biom_output_file, metadata_output_file, partition = sys.argv[1:]

    logger = setup_logging(partition)
    filter_datasets(biom_table, metadata, biom_output_file, metadata_output_file, logger)
