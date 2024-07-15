#Code to replicate Bombus synteny analysis
#See the manual of JCVI for your own purposes, as this may become out of data
#See the github account for: tanghaibao/jcvi

#${gff} should be replaced with your gff file.
#${fasta} should be your genome in fasta format.
#${sample_id} is for your Sample name (two species)

# Reformat the input to compatible:
#SPECIES 1 -Run the basic transformation of gff to bed and fasta to cds conversions.
python -m jcvi.formats.gff bed --type=mRNA --key=ID ${gff} -o ${sample_id}.bed
python -m jcvi.formats.fasta format ${fasta} ${sample_id}.cds
#SPECIES 2 -Run the basic transformation of gff to bed and fasta to cds conversions.
python -m jcvi.formats.gff bed --type=mRNA --key=ID ${gff2} -o ${sample_id2}.bed
python -m jcvi.formats.fasta format ${fasta2} ${sample_id2}.cds

# Run main syntenic comparison code:
python -m jcvi.compara.catalog ortholog ${sample_id} ${sample_id2} --no_strip_names
python -m jcvi.compara.synteny depth --histogram ${sample_id}.${sample_id2}.anchors
python -m jcvi.compara.synteny screen --minspan=30 --simple ${sample_id}.${sample_id2}.anchors ${sample_id}.${sample_id2}.anchors.new
    
# To get ribbon plot with 3 species:

#You need to manually curate a list of chromosomes to show (seqids_karyotype_all.txt):

#chr1,chr2,chr3,chr4
#scaffold_1,scaffold_2

#Then build a plot data table (layout_all)
# y, xstart, xend, rotation, color, label, va,  bed
# .7,     .1,    .8,      15,      , Bombus_impatiens3, top, bimp3.bed
# .5,     .1,    .8,       0,      , Apis_mellifera, top, apis.bed
# .3,     .1,    .8,     -15,      , Bombus_impatiens2, bottom, bimp2.bed
# edges
#e, 0, 1, bimp3.apis.anchors.simple
#e, 1, 2, apis.bimp2.anchors.simple


python -m jcvi.graphics.karyotype seqids_karyotype_all.txt layout_all
