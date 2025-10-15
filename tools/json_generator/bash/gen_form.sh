#!/bin/bash

##########################################
# Script for generating a text form for the Boamps data model
# Author : dfovet
# Version : 1.0
# Date : 20251010
#########################################

##########################################
# Usage
#########################################
usage()
{
echo "-----------------------------------------------------"
echo "Wrong Usage WARNING"
echo "-----------------------------------------------------"
echo "Purpose of the script: Generate a form for the ai power measurement data model : Boamps"
echo ""
echo "Command structure: "
echo "./gen_form_en.sh <Generation Type> <Reference CSV> <Parameter File> <Input File Name> <Input File Line Number to Integrate>"
echo "example1 : ./gen_form.sh -a data/conf/boamps_auto_prefill_codecarbon.csv data/conf/config_nb_fields_boamps.conf > report1.txt"
echo "example2 : ./gen_form.sh -a data/conf/boamps_auto_prefill_codecarbon.csv data/conf/config_nb_fields_boamps.conf data/input/codecarbon_file.csv 2 > report-codecarbon-prefill.txt"
echo "<Generation Type>"
echo " -a for ALL generates a form including mandatory and optional fields"
echo "<Reference CSV>"
echo "Descriptive file of the data model including or not the references to fill the form from a CSV"
echo "Example: boamps_auto_prefill_codecarbon.csv To pre-fill the form from a CodeCarbon csv"
echo "<Parameter File>"
echo "File allowing to modulate the number of sections in the form"
echo "Example: config_nb_fields_boamps.conf to pre fill the form with the right number of tables to describe an inference"
echo "<Input File Name>"
echo "Input file in csv format containing the results of your power measurements"
echo "<Input File Line Number to Integrate>"
echo "The line number containing the result to convert to boamps format, the header is the line 0 so you need to write 1 to have the first line of data"
}

##########################################
# Log Management
#########################################
tolog()
{
LOGTIMETAG=`date +%Y\;%m\;%d\;%H\;%M\;%S\;%N`
echo "$LOGTIMETAG--$1" >> $2
echo "$LOGTIMETAG--$1"
}

tolognodate()
{
LOGTIMETAG=`date +%Y\;%m\;%d\;%H\;%M\;%S\;%N`
echo "$1" >> $2
echo "$LOGTIMETAG--$1"
}

##########################################
# Read from a file table separated by ,
#########################################
readtab() {
  local csvfile="$1"
  local col="$2"
  local row="$3"
  awk -F',' "NR==$row {gsub(/[\r\n]+/,\"\"); for(i=1;i<=NF;i++) gsub(/^ +| +$/, \"\", \$i); print \$${col}}" "$csvfile"
}

##########################################
# Write a formatted output line with tabulation and comments at tabcomment char at the start of the line
##########################################
write_real_line()
{
    j=0
    tabcomment=100
    tabF=0
    if [[ $4 != 0 ]]
    then
        for j in `seq 1 1 $4`
        do
            echo -ne " |  "
            let tabF++
        done
    fi
    echo -n "$2"
    size=${#2}
    tabflo=$(($tabF*4))
    tabtot=$(($tabflo+$size))
    j=0
    for j in `seq $tabtot 1 $tabcomment`
    do
        echo -ne " "
    done
    echo "$3"
}

write_line()
{
    case $5 in
        "A")
        write_real_line "$1" "$2" "$3" "$4"
        ;;

        "M")
        if [[ $1 = "MANDATORY" ]]
        then
        write_real_line "$1" "$2" "$3" "$4"
        fi
        ;;
    esac
}

##########################################
# Read in a string what is between = and # then remove spaces
#########################################
readlineval()
{
    j=$2
    RES=""
    RES=$(sed -n ''$j','$j' p' $1 | sed 's/.*=\(.*\)#.*/\1/' | tr -d ' ')
    echo "$RES"
}

##########################################
# Read from a file table separated by ; find a certain column by its name and take the value of the requested row
#gettabcolval $inputcsv $strCmd $ligneinput $nbentry
#########################################
gettabcolval()
{
  csvfile=$1
  test=$2
  rowc=$3 #min=2 because 1 means the head of csv
  numit=$4
  nbsep=0
  for (( k=0; k<${#test}; k++))
  do
    tmp=${test:$k:1}
    if [[ $tmp == ":" ]]
    then
      let "nbsep++"
    fi
  done
  if [[ $test != "no" ]]
  then
    if [[ $((nbsep+1)) -ge $numit ]]
    then
      VAL1=$(echo $test | awk -v idx=$numit -F':' '{print $idx}')
      if [[ ${VAL1:0:1} == "#" ]]
      then
        RES=$(echo $VAL1 | awk -v idx=2 -F'#' '{print $idx}')
        echo $RES
      else
        j=0
        csvhead=$(sed -n ''1','1' p' $csvfile)
        for (( i=1; i<${#csvhead}; i++))
        do
        val=$(readtab $csvfile $i 1)
          if [[ $val == "" ]]
          then
            i=${#csvhead}
          elif [[ $val == $VAL1 ]]
          then
            j=$i
            i=${#csvhead}
          fi
        done
        if [[ $j -ne 0 ]]
        then
          val=$(readtab $csvfile $j $rowc)
          echo $val
        fi
      fi
    fi
  fi
}

##########################################
# Init variables
#########################################
DATETAG=`date +%y%m%d-%H%M`
BASEDIR=$(pwd)
BASENAME0=$(basename "$0")
LOGDIR="$BASEDIR/Log"
NPARAMS=3
NPARAMSMAX=5
LOGFILE="$LOGDIR/$BASENAME0_$2_$DATETAG.log"
RESULTFILE="$LOGDIR/Result_$BASENAME0_$2_$DATETAG.log"
ficRef=$2
ficConf=$3
inputcsv=$4
ligneinput=$5
let "ligneinput++"
nbligneparam=$(wc -l < $ficRef)
HorizT='├'
ELine='└'
nbtab=0
nbtable=0
nbentry=1
startChar=$HorizT
refline=2
tableList=();
reflineList=();
refList=();

#################################################################
## Check the number of params
#################################################################
if [[ $# -lt "$NPARAMS" ]] || [[ $# -gt "$NPARAMSMAX" ]]
   then
       echo "this script needs $NPARAMS input arguments!"
       echo "Number of params : $#"
       usage
exit 0
fi

#################################################################
## Select execution mode
#################################################################
case $1 in
 "-a")
  mode="A"
  ;;
 *)
  echo "BAD Argument : $1"
        usage
        exit 0
esac

#################################################################
## Retrieve generation params based on info from the config file: form_gen.conf
#################################################################
nbAlgo=$(($(readlineval $ficConf 2) ))
nbDataset=$(($(readlineval $ficConf 3) ))
nbDatasetShape=$(($(readlineval $ficConf 4) ))
datasetInferenceProperties=$(($(readlineval $ficConf 5) ))
nbMeasures=$(($(readlineval $ficConf 6) ))
infraComponents=$(($(readlineval $ficConf 7) ))

#################################################################
## Declaration in the form file of the params used to generate this form
## WARNING: This info will be used for transformation to JSON via form2json.sh
#################################################################
echo "[Config]  # DO NOT MODIFY"
echo " ├nbAlgo=$nbAlgo                                              #Number of Algorithm object occurrences in the form"
echo " ├nbDataset=$nbDataset                                        #Number of Dataset object occurrences in the form"
echo " ├nbDatasetShape=$nbDatasetShape                              #Number of Shape object occurrences per Dataset in the form"
echo " ├datasetInferenceProperties=$datasetInferenceProperties      #Number of InferenceProperties object occurrences per Dataset in the form"
echo " ├nbMeasures=$nbMeasures                                      #Number of Measures object occurrences in the form"
echo " ├infraComponents=$infraComponents                            #Number of Components object occurrences in the form"
echo " └"

##########################################
# We go through the reference table and build for each line the correct form line
#########################################
for (( refline=2; refline<=$nbligneparam; refline++ ))
do
    #We retrieve the information from the reference table line
    strName=$(readtab $ficRef 4 $refline)
    strType=$(readtab $ficRef 6 $refline)
    strMandatory=$(readtab $ficRef 7 $refline)
    strCmd=$(readtab $ficRef 9 $refline)
    strEnum=$(readtab $ficRef 10 $refline)
    strQuestion=$(readtab $ficRef 12 $refline)
    strComment=$(readtab $ficRef 13 $refline)

    #Here we check if an entry is mandatory
    if [[ "$strMandatory" == "TRUE" ]]
    then
        strMandatory="MANDATORY"
    else
        strMandatory="OPTIONAL"
    fi

    #Here, depending on the entry type, we format and generate the text line sent to the write_line function
    case $strType in

        "Object")
            array=("header${IFS}task${IFS}measures${IFS}system${IFS}software${IFS}infrastructure${IFS}environment${IFS}\$hash")
            if [[ "${IFS}${array[*]}${IFS}" =~ "${IFS}${strName}${IFS}" ]]; then
                inputtmp="[$strName]"
                commenttmp="#$strMandatory : $strComment"
                write_line "$strMandatory" "$inputtmp" "$commenttmp" $nbtab $mode
            else
                let "nbtab++"
                inputtmp="[$strName]"
                commenttmp="#$strMandatory : $strComment"
                write_line "$strMandatory" "$inputtmp" "$commenttmp" $nbtab $mode
            fi
            ;;

        "Enum")
            if [[ -f $inputcsv ]]
            then
              valtmp=$(gettabcolval $inputcsv "$strCmd" $ligneinput $nbentry)
            else
              valtmp=""
            fi
            if [[ $strName = "quality" ]]
            then
                inputtmp="$strQuestion=$valtmp"
                commenttmp="#$strMandatory value in {$strEnum} : $strComment"
                write_line "$strMandatory" "$inputtmp" "$commenttmp" $nbtab $mode
            else
                inputtmp=" $startChar$strQuestion=$valtmp"
                commenttmp="#$strMandatory value in {$strEnum} : $strComment"
                write_line "$strMandatory" "$inputtmp" "$commenttmp" $nbtab $mode
            fi
            ;;

        "String")
            if [[ -f $inputcsv ]]
            then
              valtmp=$(gettabcolval $inputcsv "$strCmd" $ligneinput $nbentry)
            else
              valtmp=""
            fi
            inputtmp=" $startChar$strQuestion=$valtmp"
            commenttmp="#$strMandatory as {$strType} : $strComment"

            write_line "$strMandatory" "$inputtmp" "$commenttmp" $nbtab $mode
            ;;

        "Integer")
            if [[ -f $inputcsv ]]
            then
              valtmp=$(gettabcolval $inputcsv "$strCmd" $ligneinput $nbentry)
            else
              valtmp=""
            fi
            inputtmp=" $startChar$strQuestion=$valtmp"
            commenttmp="#$strMandatory as {$strType} : $strComment"
            write_line "$strMandatory" "$inputtmp" "$commenttmp" $nbtab $mode
            ;;

        "Float")
            if [[ -f $inputcsv ]]
            then
              valtmp=$(gettabcolval $inputcsv "$strCmd" $ligneinput $nbentry)
            else
              valtmp=""
            fi
            inputtmp=" $startChar$strQuestion=$valtmp"
            commenttmp="#$strMandatory as {$strType} : $strComment"
            write_line "$strMandatory" "$inputtmp" "$commenttmp" $nbtab $mode
            ;;

        "Boolean")
            if [[ -f $inputcsv ]]
            then
              valtmp=$(gettabcolval $inputcsv "$strCmd" $ligneinput $nbentry)
            else
              valtmp=""
            fi
            inputtmp=" $startChar$strQuestion=$valtmp"
            commenttmp="#$strMandatory as {$strType} : $strComment"
            write_line "$strMandatory" "$inputtmp" "$commenttmp" $nbtab $mode
            ;;

        "Table")
            if [[ $nbtable -ne 0 ]]
            then
                if [[ ${tableList[$((nbtable-1))]} != "$strName" ]]
                then
                    tableList[$nbtable]="$strName"
                    reflineList[$nbtable]="$refline"
                    refList[$nbtable]=1
                    nbentry=1
                    let "nbtable++"
                fi
            else
                tableList[$nbtable]="$strName"
                reflineList[$nbtable]="$refline"
                refList[$nbtable]=1
                let "nbtable++"
            fi

            IFS="|"
            array=("header${IFS}task${IFS}system${IFS}software${IFS}infrastructure${IFS}environment${IFS}\$hash")
            isInArray="$strName"
            if [[ "${IFS}${array[*]}${IFS}" =~ "${IFS}${isInArray}${IFS}" ]]; then
                inputtmp=" $startChar($strName)"
                commenttmp="#$strMandatory : $strComment"
            else
                inputtmp=" $startChar($strName.$nbentry)"
                commenttmp="#$strMandatory : $strComment"
            fi

            unset IFS
            write_line "$strMandatory" "$inputtmp" "$commenttmp" $nbtab $mode
            let "nbtab++"
            ;;

        "TableEnd")
            write_line "$strMandatory" " $ELine" "" $nbtab $mode
            array=("header End${IFS}task End${IFS}values End${IFS}shape End${IFS}inferenceProperties End${IFS}components End${IFS}algorithms End${IFS}dataset End${IFS}measures End${IFS}system End${IFS}software End${IFS}infrastructure End${IFS}environment End${IFS}\$hash End")
            isInArray="$strName"

            if [[ "${IFS}${array[*]}${IFS}" =~ "${IFS}${isInArray}${IFS}" ]]; then
                if [ $nbtab -gt 0 ]; then let "nbtab--" ; fi
            fi

            tableList=(${tableList[@]:0:$nbtable} ${tableList[@]:$(($nbtable + 1))})

            #Here, to allow generating a number of occurrences of certain objects, we capture the position in the array of the object start
            if [[ $strName == "algorithms End" ]]; then nbIter=$nbAlgo ; fi
            if [[ $strName == "shape End" ]]; then nbIter=$nbDatasetShape ; fi
            if [[ $strName == "inferenceProperties End" ]]; then nbIter=$datasetInferenceProperties ; fi
            if [[ $strName == "components End" ]]; then nbIter=$infraComponents ; fi
            if [[ $strName == "dataset End" ]]; then nbIter=$nbDataset ; fi
            if [[ $strName == "measures End" ]]; then nbIter=$nbMeasures ; fi

            #Here, depending on the number of occurrences, we iterate in the param array to write several tables
            if [[ ${refList[$((nbtable-1))]} < $nbIter ]]; then
                refList[$((nbtable-1))]=$((refList[$((nbtable-1))] + 1))
                nbentry=${refList[$((nbtable-1))]}
                refline=$((reflineList[$((nbtable-1))] - 1))
            else
                let "nbtable--"
                refList=(${refList[@]:0:$nbtable} ${refList[@]:$(($nbtable + 1))})
                tableList=(${tableList[@]:0:$nbtable} ${tableList[@]:$(($nbtable + 1))})
                reflineList=(${reflineList[@]:0:$nbtable} ${reflineList[@]:$(($nbtable + 1))})
                nbentry=1
            fi
            ;;

        "ObjectEnd")
            #
            array=("header End${IFS}task End${IFS}measures End${IFS}system End${IFS}software End${IFS}infrastructure End${IFS}environment End${IFS}\$hash End")
            isInArray="$strName"

            if [[ "${IFS}${array[*]}${IFS}" =~ "${IFS}${isInArray}${IFS}" ]]; then
                if [ $nbtab -gt 0 ]; then let "nbtab--" ; fi
            fi

            write_line "$strMandatory" " $ELine" "" $nbtab $mode

            array=("hyperparameters End${IFS}inferenceProperties End${IFS}parametersNLP End")
            isInArray="$strName"

            if [[ "${IFS}${array[*]}${IFS}" =~ "${IFS}${isInArray}${IFS}" ]]; then
                if [ $nbtab -gt 0 ]; then let "nbtab--" ; fi
            fi
            ;;

    esac

done