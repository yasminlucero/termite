#!/bin/bash

if [ $# -lt 2 ]
then
	echo "Usage: `basename $0` corpus_filename corpus_identifier num_topics"
	echo
	exit -1
fi

MALLET=tools/mallet-2.0.7
CORPUS_FILENAME=$1
RUN_IDENTIFIER=$2
if [ $# -ge 3 ]
then
	NUM_TOPICS=$3
else
	NUM_TOPICS=25
fi

INPUT_FILENAME=data/$RUN_IDENTIFIER/$RUN_IDENTIFIER.mallet
LDA_FOLDER=data/$RUN_IDENTIFIER/lda
ENTRY_FOLDER=data/$RUN_IDENTIFIER/entry-0000

#------------------------------------------------------------------------------#

function __create_folder__ {
	FOLDER=$1
	if [ ! -d $FOLDER ]
	then
		echo "Creating folder: $FOLDER"
		mkdir $FOLDER
	fi
}

__create_folder__ data
__create_folder__ data/$RUN_IDENTIFIER
__create_folder__ $LDA_FOLDER
__create_folder__ $ENTRY_FOLDER

echo "Importing corpus into Mallet: [$CORPUS_FILENAME] --> [$INPUT_FILENAME]"
$MALLET/bin/mallet import-file \
	--input $CORPUS_FILENAME \
	--output $INPUT_FILENAME \
	--remove-stopwords \
	--token-regex "\p{Alpha}{3,}" \
	--keep-sequence

echo "Building a topic model: [$NUM_TOPICS topics]"
$MALLET/bin/mallet train-topics \
	--input $INPUT_FILENAME \
	--output-model $LDA_FOLDER/output.model \
	--output-topic-keys $LDA_FOLDER/output-topic-keys.txt \
	--topic-word-weights-file $LDA_FOLDER/topic-word-weights.txt \
	--word-topic-counts-file $LDA_FOLDER/word-topic-counts.txt \
	--num-topics $NUM_TOPICS

echo "Extracting topic model outputs: [$LDA_FOLDER] --> [$ENTRY_FOLDER]"
src/ReadMallet.py $LDA_FOLDER $ENTRY_FOLDER
