#!/bin/sh

### this script downloads the biom table and sample metadata from all individuals in the American Gut Project:
### with a skin condition but WITHOUT IBD/IBS

# Define file paths
SAMPLE_FILE1="../samples/skin_disease_pos.txt"
SAMPLE_FILE2="../samples/ibd_neg.txt"
SAMPLE_FILE3="../samples/ibs_neg.txt"
SAMPLE_FILE="../samples/skin_pos_and_gut_neg_metadata.txt"

TBL_FILE="../tables/skin_pos_and_gut_neg.biom"
MD_FILE="../metadata/skin_pos_and_gut_neg.tsv"

# Define Redbiom context (CTX)
CTX="Woltka-per-genome-WoLr2-3ab352"

# Define functions
search_metadata() {
    redbiom search metadata "$1" | grep -vi "blank" > "$2"
}

fetch_samples() {
    redbiom fetch samples \
        --from "$1" \
        --context "$2" \
        --output "$3" \
        #--resolve-ambiguities "most-reads"
}

fetch_metadata() {
    redbiom fetch sample-metadata \
        --from "$1" \
        --context "$2" \
        --output "$3" \
        --all-columns \
        #--resolve-ambiguities "most-reads"
        # resolve ambiguities will strip off the artifact IDs, and collapse the data based on the observed <qiita_study_id>.<sample_id> identifier
}

# Activate conda environment and check redbiom version
source /Users/yac027/mambaforge3/etc/profile.d/conda.sh
conda activate redbiom
redbiom --version

# Search metadata
echo "Searching metadata via redbiom..."
search_metadata "where (qiita_study_id == 10317 and env_package=='human-gut') and (skin_condition == 'Diagnosed by a medical professional (doctor, physician assistant)')" "$SAMPLE_FILE1"
search_metadata "where (qiita_study_id == 10317 and env_package=='human-gut') and (ibd == 'I do not have this condition')" "$SAMPLE_FILE2"
search_metadata "where (qiita_study_id == 10317 and env_package=='human-gut') and (ibs == 'I do not have this condition')" "$SAMPLE_FILE3"

cat "$SAMPLE_FILE1" "$SAMPLE_FILE2" "$SAMPLE_FILE3" > "$SAMPLE_FILE"

# Fetch samples
echo "Grabbing per-genome biom table..."
fetch_samples "$SAMPLE_FILE" "$CTX" "$TBL_FILE"
echo "All biom tables outputed!"

# Fetch metadata
echo "Fetching sample metadata via redbiom..."
fetch_metadata "$SAMPLE_FILE" "$CTX" "$MD_FILE"

echo "Grabbing per-genome biom table..."
fetch_samples "$SAMPLE_FILE" "$CTX" "$TBL_FILE"

echo "Fetching sample metadata via redbiom..."
fetch_metadata "$SAMPLE_FILE" "$CTX" "$MD_FILE"

echo "Finished!"