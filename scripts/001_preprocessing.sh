#!/bin/bash

##############################################
# mRNA Preprocessing Pipeline - Bash Script
# Steps:
#   1. FastQC (raw reads)
#   2. Trimming with fastp
#   3. Host read removal with Bowtie2 (GRCh38)
#   4. rRNA removal using SortMeRNA
##############################################

# --------- Input files from each site -------------
R1="R1.fastq.gz"
R2="R2.fastq.gz"
OUTDIR="results"
mkdir -p $OUTDIR

# --------- 1. QC - FastQC ----------
echo "Running FastQC..."
fastqc $R1 $R2 -o $OUTDIR/fastqc_raw

# --------- 2. Trimming - fastp -----
echo "Running fastp trimming..."
fastp \
  -i $R1 \
  -I $R2 \
  -o $OUTDIR/sample_trimmed_R1.fastq.gz \
  -O $OUTDIR/sample_trimmed_R2.fastq.gz \
  --detect_adapter_for_pe \
  --thread 8 \
  --html $OUTDIR/fastp_report.html \
  --json $OUTDIR/fastp_report.json

TRIM_R1="$OUTDIR/sample_trimmed_R1.fastq.gz"
TRIM_R2="$OUTDIR/sample_trimmed_R2.fastq.gz"

# --------- 3. Host Removal (Bowtie2) -----
echo "Removing host (human) reads..."
bowtie2 \
  -x /path/to/bowtie2/GRCh38_index \
  -1 $TRIM_R1 \
  -2 $TRIM_R2 \
  --threads 8 \
  --very-sensitive \
  --un-conc-gz $OUTDIR/sample_nonhuman.fastq.gz \
  -S $OUTDIR/sample_hostaligned.sam

NONHOST_R1="$OUTDIR/sample_nonhuman.1.fastq.gz"
NONHOST_R2="$OUTDIR/sample_nonhuman.2.fastq.gz"

# --------- 4. rRNA Removal (SortMeRNA) -----
echo "Running SortMeRNA rRNA filtering..."
sortmerna \
  --ref /path/to/rRNA_db.fasta \
  --reads $NONHOST_R1 \
  --reads $NONHOST_R2 \
  --workdir $OUTDIR/sortmerna_output \
  --fastx \
  --paired_in \
  --other $OUTDIR/sample_mRNA_non_rRNA

# Output files:
#   sample_mRNA_non_rRNA.fastq  (non-rRNA reads)

echo "Pipeline complete!"
