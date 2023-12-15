import biom
from biom.util import biom_open
from biom import Table
import pandas as pd
import logging
import sys

# Set up logging
logging.basicConfig(filename='../log/{partition}/filter_duplicate_samples.log', level=logging.INFO)

def filter_datasets(biom_table, metadata, biom_output_file, metadata_output_file, partition):
    # drop duplicate rows in the metadata df
    logging.info(f'Starting number of samples: {metadata.shape[0]}')
    metadata_filtered = metadata.drop_duplicates(subset='host_subject_id', keep='first')
    logging.info(f'Number of samples after dropping duplicates: {metadata_filtered.shape[0]}')

    # Save filtered metadata
    metadata_filtered.to_csv(metadata_output_file, sep='\t', index=False)

    # Load biom table
    with biom_open(biom_table) as f:
        table = Table.from_hdf5(f)

    # Identify duplicate samples
    duplicate_samples = metadata[metadata.duplicated('host_subject_id')]['host_subject_id'].tolist()

    # Remove duplicate samples from biom table
    table.filter(duplicate_samples, axis='sample', inplace=True)

    # Save filtered biom table
    with biom_open(biom_output_file, 'w') as f:
        table.to_hdf5(f)

if __name__ == "__main__":
    if len(sys.argv) != 6:
        print("Usage: python filter_samples.py <biom_table> <metadata> <biom_output_file> <metadata_output_file> <partition>")
        sys.exit(1)

    biom_table, metadata, biom_output_file, metadata_output_file, partition = sys.argv[1:]

    filter_datasets(biom_table, metadata, biom_output_file, metadata_output_file, partition)
