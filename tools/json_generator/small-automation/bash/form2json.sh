#!/bin/bash

##########################################
# Script de Generation et mise au format du datamodel AI power measurement sharing
# Author : dfovet
# Version : 0.1
# Date : 20240731
#########################################

##########################################
# Usage et check du nombre de params
#########################################
usage()
{
echo "-----------------------------------------------------"
echo "Mauvais Usage ATTENTION"
echo "-----------------------------------------------------"
echo "But du script : Transformer un rapport au format texte en un json suivant le modele de donnees ai power measurements"
echo ""
echo "Structure de la commande : "
echo "./form2json.sh <Fichier formulaire a convertir> > <Nom du fichier de sortie>"
echo "exemple: ./form2json.sh form_example.txt > json_example.json"

}

##########################################
# Gestion de Log
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
# Lire dans un fichier tableau separe par des ;
#########################################
readtab()
{
    i=$2
    j=$3
    RES=""
    RES=$(sed -n ''$j','$j' p' $1 | awk -v idx=$i -F';' '{print $idx}')
    echo "$RES"
}

##########################################
# Lire dans un string ce qu'il y a entre le = et le # ensuite on supprime les espaces
#########################################
readlineval()
{
    j=$2
    RES=""
    #echo "<some text>=someuser@somedomain.com #<some text>" | sed 's/.*=\(.*\)#.*/\1/'
    RES=$(sed -n ''$j','$j' p' $1 | sed 's/.*=\(.*\)#.*/\1/' | tr -d ' ')
    echo "$RES"
}


##########################################
# Ecrit un nombre donne en param d indentation
##########################################
indentification()
{
    j=0
    tot=$1
    if [[ $tot != 0 ]]
    then
        for (( j=1; j<=$tot; j++ ))
        do
            echo -ne "\t"
        done
    fi
}

##########################################
# Init des variables
#########################################
DATETAG=`date +%y%m%d-%H%M`
BASEDIR=$(pwd)
BASENAME0=$(basename "$0")
LOGDIR="$BASEDIR/Log"
NPARAMS=2
LOGFILE="$LOGDIR/$BASENAME0_$2_$DATETAG.log"
RESULTFILE="$LOGDIR/Result_$BASENAME0_$2_$DATETAG.log"
ficForm=$2
nbtab=0
HorizT='├'
HLine='─'
ELine='└'
nbtable=0
nbentry=1
startChar=$HorizT
idreadline=10
refline=2
indent=0
endline=""
tableList=();
reflineList=();
refList=();


#################################################################
## Verification du nombre de param
#################################################################
if [[ $# -lt "$NPARAMS" || $# -gt "$NPARAMS" ]]
   then
       echo "ce script a besoin de $minparams arguments en entree!"
       echo "Liste des arguments passes en parametre : $@"
       usage
exit 0
fi

#################################################################
## Selection du mode d'execution
#################################################################
case $1 in 
	"-a")
		mode="A"
		;;
	"-m")
		mode="M"
		;;
	*)
		echo "BAD Argument : $1"
        usage
        exit 0
esac

#################################################################
## Init des params de generation en fonction des infos contenues dans le formulaire pour plus de securite
#################################################################
nbAlgo=$(readlineval $ficForm 2)
nbAlgoHyperparamVal=$(readlineval $ficForm 3)
nbDataset=$(readlineval $ficForm 4)
nbDatasetShape=$(readlineval $ficForm 5)
datasetInferenceProperties=$(readlineval $ficForm 6)
nbMeasures=$(readlineval $ficForm 7)
infraComponents=$(readlineval $ficForm 8)

#################################################################
## On ecrit ici le debut du fichier json
#################################################################

echo "{"
let "indent++"

########################################## 
# On parcourt le tableau de references et on construit pour chaque ligne la version fichier texte
#########################################
for (( refline=2; refline<=113; refline++ ))
do
    #On recupere les informations de la ligne du tableau de reference
    strID=$(readtab ./references.param 1 $refline)
    strContext=$(readtab ./references.param 2 $refline)
    strCategorie=$(readtab ./references.param 3 $refline)
    strName=$(readtab ./references.param 4 $refline)
    strSubObject=$(readtab ./references.param 5 $refline)
    strType=$(readtab ./references.param 6 $refline)
    strMandatory=$(readtab ./references.param 7 $refline)
    strAuto=$(readtab ./references.param 8 $refline)
    strCmd=$(readtab ./references.param 9 $refline)
    strEnum=$(readtab ./references.param 10 $refline)
    strDefvalue=$(readtab ./references.param 11 $refline)
    strQuestion=$(readtab ./references.param 12 $refline)
    strComment=$(readtab ./references.param 13 $refline)
    strNextType=$(readtab ./references.param 6 $((refline + 1)))


    if [[ "$strMandatory" == "TRUE" ]] 
    then       
        strMandatory="MANDATORY"
    else
        strMandatory="OPTIONAL"
    fi

    if [[ "$strNextType" != "ObjectEnd" ]] && [[ "$strNextType" != "TableEnd" ]] && [[ "$strNextType" != "" ]] 
    then       
        endline=","
    else
        endline=""
    fi

    case $strType in
            
        "Object")
            indentification $indent
            echo "\"$strName\": {"
            let "indent++"
            ;;

        "Enum")
            value=$(readlineval $ficForm $idreadline)
            indentification $indent
            echo "\"$strName\":\"$value\"$endline"
            ;;
            
        "String")
            value=$(readlineval $ficForm $idreadline)
            indentification $indent
            echo "\"$strName\":\"$value\"$endline"
            ;;
            
        "Integer")
            value=$(readlineval $ficForm $idreadline)
            indentification $indent
            echo "\"$strName\":\"$value\"$endline"
            ;;

        "Float")
            value=$(readlineval $ficForm $idreadline)
            indentification $indent
            echo "\"$strName\":\"$value\"$endline"
            ;;

        "Boolean")
            value=$(readlineval $ficForm $idreadline)
            indentification $indent
            echo "\"$strName\":\"$value\"$endline"
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
                    echo "$(indentification $indent)\"$strName\": ["
                    let "indent++"
                    echo "$(indentification $indent){"

                fi
            else
                tableList[$nbtable]="$strName"
                reflineList[$nbtable]="$refline"
                refList[$nbtable]=1

                let "nbtable++"
                echo "$(indentification $indent)\"$strName\": ["
                let "indent++"
                echo "$(indentification $indent){"

            fi
            
            let "nbtab++" 

            ;;
       
        "TableEnd")
            
            array=("header End${IFS}task End${IFS}values End${IFS}shape End${IFS}inferenceProperties End${IFS}components End${IFS}algorithms End${IFS}dataset End${IFS}measures End${IFS}system End${IFS}software End${IFS}infrastructure End${IFS}environment End${IFS}\$hash End")
            isInArray="$strName"

            if [[ "${IFS}${array[*]}${IFS}" =~ "${IFS}${isInArray}${IFS}" ]]; then
                if [ $nbtab -gt 0 ]; then let "nbtab--" ; fi
            fi
            
            tableList=(${tableList[@]:0:$nbtable} ${tableList[@]:$(($nbtable + 1))})

            if [[ $strName == "algorithms End" ]]; then nbIter=$nbAlgo ; fi
            if [[ $strName == "values End" ]]; then nbIter=$nbAlgoHyperparamVal ; fi
            if [[ $strName == "shape End" ]]; then nbIter=$nbDatasetShape ; fi
            if [[ $strName == "inferenceProperties End" ]]; then nbIter=$datasetInferenceProperties ; fi
            if [[ $strName == "components End" ]]; then nbIter=$infraComponents ; fi
            if [[ $strName == "dataset End" ]]; then nbIter=$nbDataset ; fi
            if [[ $strName == "measures End" ]]; then nbIter=$nbMeasures ; fi

            if [[ ${refList[$((nbtable-1))]} < $nbIter ]]; then
                refList[$((nbtable-1))]=$((refList[$((nbtable-1))] + 1))
                nbentry=${refList[$((nbtable-1))]}
                refline=$((reflineList[$((nbtable-1))] - 1))

                echo "$(indentification $indent)}$endline"
                echo "$(indentification $indent){"

            else
                let "nbtable--"
                refList=(${refList[@]:0:$nbtable} ${refList[@]:$(($nbtable + 1))})
                tableList=(${tableList[@]:0:$nbtable} ${tableList[@]:$(($nbtable + 1))})
                reflineList=(${reflineList[@]:0:$nbtable} ${reflineList[@]:$(($nbtable + 1))})
                nbentry=1

                echo "$(indentification $indent)}"
                let "indent--"  
                echo "$(indentification $indent)]$endline"

            fi  
            
            ;;
       
        "ObjectEnd")
            array=("header End${IFS}task End${IFS}measures End${IFS}system End${IFS}software End${IFS}infrastructure End${IFS}environment End${IFS}\$hash End")
            isInArray="$strName"

            if [[ "${IFS}${array[*]}${IFS}" =~ "${IFS}${isInArray}${IFS}" ]]; then 
                if [ $nbtab -gt 0 ]; then let "nbtab--" ; fi
            fi

            array=("hyperparameters End${IFS}parametersNLP End")
            isInArray="$strName"

            if [[ "${IFS}${array[*]}${IFS}" =~ "${IFS}${isInArray}${IFS}" ]]; then
                if [ $nbtab -gt 0 ]; then let "nbtab--" ; fi
            fi
            
            echo "$(indentification $indent)}$endline"
            let "indent--"

            ;;

    esac

    IFS="|"

    value=""
    let "idreadline++"

    done

#on finalise le json avec la derniere accolade
echo "}"