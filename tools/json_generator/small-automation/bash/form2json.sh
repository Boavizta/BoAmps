#!/bin/bash

##########################################
# Script de mise au format json d'un formulaire texte generé par gen_form.sh lié au datamodel Boamps
# Author : dfovet
# Version : 0.86
# Date : 20250609
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
echo "./form2json.sh <Type de generation> <CSV de reference> <Fichier formulaire a convertir>"
echo "exemple: ./form2json.sh -a Ref_CodeCarbon.csv report1.txt > json_example.json"
echo "<Type de generation>"
echo " -a pour ALL genere un formulaire incluant les champs obligatoires et facultatifs"
echo "<CSV de reference>"
echo "Fichier descriptif du model de données de preference le même que celui utilisé lors de la generation du formulaire "
echo "Exemple : Ref_CodeCarbon.csv Pour préremplir dans le formulaire a partir d'un csv CodeCarbon"
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
NPARAMS=3
LOGFILE="$LOGDIR/$BASENAME0_$2_$DATETAG.log"
RESULTFILE="$LOGDIR/Result_$BASENAME0_$2_$DATETAG.log"
ficRef=$2
ficForm=$3
nbligneparam=$(wc -l < $ficRef)
nbtab=0
nbtable=0
nbentry=1
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
       echo "ce script a besoin de $NPARAMS arguments en entree!"
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
for (( refline=2; refline<=$nbligneparam; refline++ ))
do
    #On recupere les informations de la ligne du tableau de reference
    strName=$(readtab $ficRef 4 $refline)
    strType=$(readtab $ficRef 6 $refline)
    strMandatory=$(readtab $ficRef 7 $refline)
    strNextType=$(readtab $ficRef 6 $((refline + 1)))

    #Ici on teente de gerer le cote mandatory mais pas completement testé dans cette version
    if [[ "$strMandatory" == "TRUE" ]] 
    then       
        strMandatory="MANDATORY"
    else
        strMandatory="OPTIONAL"
    fi

    #On set les characteres de fin de ligne au mieux par rapport au type suivant (changemetn d'objet ou de table
    if [[ "$strNextType" != "ObjectEnd" ]] && [[ "$strNextType" != "TableEnd" ]] && [[ "$strNextType" != "" ]]
    then
        #echo "Debug : in"
        endline=","
    else
        endline=""
    fi

    #ici on prend en compte si les champt suivant sont vide pour corriger el charactere de fin de ligne cela fonctionne aussi pour les objects et les tables
    array=("Integer${IFS}Enum${IFS}values End${IFS}String${IFS}Integer${IFS}Float${IFS}Boolean${IFS}ObjectEnd${IFS}TableEnd")
    isInArray="$strType"

    if [[ "${IFS}${array[*]}${IFS}" =~ "${IFS}${isInArray}${IFS}" ]] && [[ $strNextType != "DocumentEnd" ]]
    then
      dim=1
      videsuiv=1
      while [[ $videsuiv -eq 1 ]]
      do
        if [[ $(readlineval $ficForm $((idreadline + $dim))) == "" ]]
        then
          if [[ $(readtab $ficRef 6 $((refline + $dim + 1))) == "TableEnd" ]] || [[ $(readtab $ficRef 6 $((refline + $dim + 1))) == "ObjectEnd" ]] || [[ $(readtab $ficRef 6 $((refline + $dim + 1))) == "DocumentEnd" ]]
          then
            endline=""
            videsuiv=0
          fi
          let "dim++"
        else
          videsuiv=0
        fi
      done
    fi

    case $strType in
            
        "Object")
            indentification $indent
            echo "\"$strName\": {"
            let "indent++"
            ;;

        "Enum")
            value=$(readlineval $ficForm $idreadline)
            if [[ $value != "" ]]
            then
              indentification $indent
              echo "\"$strName\":\"$value\"$endline"
            fi
            ;;
            
        "String")
            value=$(readlineval $ficForm $idreadline)
            if [[ $value != "" ]]
            then
              indentification $indent
              echo "\"$strName\":\"$value\"$endline"
            fi
            ;;
            
        "Integer")
            value=$(readlineval $ficForm $idreadline)
            if [[ $value != "" ]]
            then
              indentification $indent
              echo "\"$strName\":$value$endline"
            fi

            ;;

        "Float")
            value=$(readlineval $ficForm $idreadline)
            if [[ $value != "" ]]
            then
              indentification $indent
              echo "\"$strName\":$value$endline"
            fi
            ;;

        "Boolean")
            value=$(readlineval $ficForm $idreadline)
            if [[ $value != "" ]]
            then
              indentification $indent
              echo "\"$strName\":\"$value\"$endline"
            fi
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

                #echo "$(indentification $indent)}$endline"
                echo "$(indentification $indent)},"
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