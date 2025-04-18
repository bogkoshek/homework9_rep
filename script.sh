#!/bin/bash

declare -A samples=(
  ["ERR14230600"]="ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR142/000/ERR14230600/ERR14230600.fastq.gz"
  ["ERR14230582"]="ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR142/082/ERR14230582/ERR14230582.fastq.gz"
  ["ERR14230595"]="ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR142/095/ERR14230595/ERR14230595.fastq.gz"
  ["ERR14230586"]="ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR142/086/ERR14230586/ERR14230586.fastq.gz"
)

for sample in "${!samples[@]}"; do
  output_file="${sample}.fastq.gz"
  curl -L ${samples[$sample]} -o "$output_file"
done

cat > run_analysis.slurm <<'EOF'
#!/bin/bash
#SBATCH --job-name=fastqc_analysis
#SBATCH --output=fastqc.log
#SBATCH --error=fastqc.err
#SBATCH --time=1:00:00
#SBATCH --mem=1G

# пути к программам
FASTQC="/home/ebogoslovskaya/.conda/envs/QC/opt/fastqc-0.12.1/fastqc"
MULTIQC="/home/ebogoslovskaya/.conda/envs/QC/bin/multiqc"

# Запускаем FastQC
"$FASTQC" ERR*.fastq.gz --noextract --threads 2

# Запускаем MultiQC
"$MULTIQC" . --filename multiqc_report.html --force
EOF

sbatch run_analysis.slurm