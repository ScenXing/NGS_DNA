#MOLGENIS walltime=03:00:00 mem=30gb ppn=5

#Parameter mapping
#string tmpName
#string stage
#string checkStage
#string tempDir
#string dedupBam
#string tmpDataDir
#string sambambaVersion
#string sambambaTool
#string dedupMetrics
#string	project
#string logsDir 
#string groupname
#string flagstatMetrics

#Load Picard module
${stage} ${sambambaVersion}
${checkStage}
sleep 5

makeTmpDir ${flagstatMetrics}
tmpFlagstatMetrics=${MC_tmpFile}

makeTmpDir ${dedupMetrics}
tmpDedupMetrics=${MC_tmpFile}

echo "starting to calculate flagstat metrics"
#make metrics file
${EBROOTSAMBAMBA}/${sambambaTool} \
flagstat \
--nthreads=4 \
${dedupBam} > ${tmpFlagstatMetrics}

mv ${tmpFlagstatMetrics} ${flagstatMetrics}
echo "moved ${tmpFlagstatMetrics} ${flagstatMetrics}"

echo -e "READ_PAIR_DUPLICATES\tPERCENT_DUPLICATION" > ${tmpDedupMetrics}
sed -n '1p;4p' ${flagstatMetrics} | awk '{print $1}' | perl -wpe 's|\n|\t|' | awk '{print $2"\t"($2/$1)*100}' >> ${tmpDedupMetrics}

echo -e "\nFlagstatMetrics calculated. Moving temp files to final.\n\n"
mv ${tmpDedupMetrics} ${dedupMetrics}
echo "moved ${tmpDedupMetrics} ${dedupMetrics}"
