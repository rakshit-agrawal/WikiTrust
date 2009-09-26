# This script is not meant to be run!
# It is simply a collection of commands, copied here as a reminder.

# Computing the statistics (can be parallelized):
/bin/gunzip -c /home/luca/wiki-data/enwiki/wiki-00100000.xml.gz \
    | ./evalwiki -compute_stats -si ~/wiki-data/enwork/stats/wiki-00100000.stats

/bin/gunzip -c /home/luca/wiki-data/enwiki/wiki-00100220.xml.gz \
    | ./evalwiki -compute_stats -si ~/wiki-data/enwork/stats/wiki-00100220.stats

# Sorting the statistics (use -n_digits 5 for small wikis):
./combinestats \
    -bucket_dir ~/wiki-data/enwork/buckets/ \
    -input_dir ~/wiki-data/enwork/stats/ \
    -n_digits 4 -use_subdirs

# Computing the reputations (whole histories):
./generate_reputation -u ~/wiki-data/enwork/reps/rep_history.txt \
    -buckets ~/wiki-data/enwork/buckets/ \
    -robots ~/wiki-data/wp_bots.txt

# Computing the reputations (only the final ones):
./generate_reputation -u ~/wiki-data/enwork/reps/rep_history.txt \
    -buckets ~/wiki-data/enwork/buckets/ \
    -robots ~/wiki-data/wp_bots.txt -write_final_reps

# ONLY IF NEEDED, remove previous version trees and sql.
sudo rm -rf /home/luca/wiki-data/enwork/blobtree
sudo rm -rf /home/luca/wiki-data/enwork/sigtree
sudo rm -rf /home/luca/wiki-data/enwork/sql/*
# Or if you can do it without being root:
rm -rf /home/luca/wiki-data/enwork/blobtree
rm -rf /home/luca/wiki-data/enwork/sigtree
rm -rf /home/luca/wiki-data/enwork/sql/*

# Generating the colored pages and the sql file for batch-online:
./evalwiki -trust_for_online \
    -historyfile ~/wiki-data/enwork/reps/rep_history.txt \
    -blob_base_path ~/wiki-data/enwork/blobtree \
    -n_sigs 8 \
    -robots ~/wiki-data/wp_bots.txt \
    -d ~/wiki-data/enwork/sql \
    /home/luca/wiki-data/enwiki/wiki-00100000.xml.gz

 ./evalwiki -trust_for_online \
    -historyfile ~/wiki-data/enwork/reps/rep_history.txt \
    -blob_base_path ~/wiki-data/enwork/blobtree \
    -n_sigs 8 \
    -robots ~/wiki-data/wp_bots.txt \
    -d ~/wiki-data/enwork/sql \
    /home/luca/wiki-data/enwiki/wiki-00100220.xml.gz

# Load the xml files in the wiki db:
cd ../test-scripts 
python load_data.py --clear_db /home/luca/wiki-data/enwiki/wiki-00100000.xml /home/luca/wiki-data/enwiki/wiki-00100220.xml
# Or simply:
python load_data.py --clear_db /home/luca/wiki-data/enwiki/wiki-00100000.xml

# clears the old wikitrust information:
python truncate_wikitrust_tables.py

# Loads the sql in the wiki db:
mysql wikidb -u wikiuser -p < ~/wiki-data/enwork/sql/wiki-00100000.sql
mysql wikidb -u wikiuser -p < ~/wiki-data/enwork/sql/wiki-00100220.sql

# Loads the reputations in the wiki db:
cd ../analysis
cat ~/wiki-data/enwork/reps/rep_history.txt | \
  ./load_reputations -db_user wikiuser -db_pass localwiki -db_name wikidb


