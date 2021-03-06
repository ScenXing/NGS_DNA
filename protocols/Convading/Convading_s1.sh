#MOLGENIS walltime=05:59:00 mem=4gb ppn=1
#string logsDir
#string groupname
#string project
#string convadingVersion
#string capturingKit
#string intermediateDir
#string capturedBed
#string convadingControlsDir
#string dedupBam
#string convadingInputBamsDir
#string convadingStartWithBam

module load ${convadingVersion}

#Function to check if array contains value
array_contains () {
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array-}"; do
        if [[ "$element" == "$seeking" ]]; then
            in=0
            break
        fi
    done
    return $in
}

makeTmpDir ${convadingStartWithBam}
tmpConvadingStartWithBam=${MC_tmpFile}

for bamFile in "${dedupBam[@]}"
do
        array_contains INPUTS "$bamFile" || INPUTS+=("$bamFile")    # If bamFile does not exist in array add it
        array_contains INPUTBAMS "$bamFile" || INPUTBAMS+=("$bamFile")    # If bamFile does not exist in array add it
done

## Creating bams directory
mkdir -p ${convadingStartWithBam}
mkdir -p ${convadingInputBamsDir} 
ln -sf ${dedupBam} ${convadingInputBamsDir}/
ln -sf ${dedupBam}.bai ${convadingInputBamsDir}/

## write capturingkit to file to make it easier to split
echo $capturingKit > ${intermediateDir}/capt.txt
CAPT=$(awk 'BEGIN {FS="/"}{print $2}' ${intermediateDir}/capt.txt)

echo $project

for i in ${INPUTS[@]}
do
	echo "$i" >> ${convadingInputBamsDir}/${CAPT}.READS.bam.list
done

perl ${EBROOTCONVADING}/CoNVaDING.pl \
-mode StartWithBam \
-inputDir ${convadingInputBamsDir} \
-outputDir ${tmpConvadingStartWithBam} \
-controlsDir ${convadingControlsDir}/${CAPT}/ \
-bed ${capturedBed} \
-rmdup

printf "moving ${tmpConvadingStartWithBam} to ${convadingStartWithBam} ... "
mv ${tmpConvadingStartWithBam}/* ${convadingStartWithBam}
printf " .. done \n"
