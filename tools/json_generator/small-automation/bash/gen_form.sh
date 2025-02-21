#!/bin/bash

##########################################
# Script de Generation et mise au format du datamodel AI power
# Author : dfovet
# Version : 0.15

# Date : 20241011
#########################################

##########################################
# Usage et check du nombre de params
#########################################
usage()
{
echo "-----------------------------------------------------"
echo "Mauvais Usage ATTENTION"
echo "-----------------------------------------------------"
echo "But du script : Generer un formulaire pour le modele de donnees ai power measurement"
echo ""
echo "Structure de la commande : "
echo "./gen_form.sh <Type de generation> <Fichier de parametres> > <Nom du fichier de sortie>"
echo "example : ./gen_form.sh -a form_gen.conf > report1.txt"
echo "<Type de generation>"
echo " -a pour ALL genere un formulaire incluant les champs obligatoires et facultatifs"
echo " -m pour MANDATORY genere un formulaire incluant les champs obligatoires seulement"
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
# Lire dans un fichier tableau séparé par des ;
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
# Ecrire une ligne output formatee avec tabulation et commentaires a tabcomment char du début de ligne
##########################################
write_real_line()
{
    j=0
    tabcomment=100
    tabF=0
    ajust=0
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
# Init des variables
#########################################
DATETAG=`date +%y%m%d-%H%M`
BASEDIR=$(pwd)
BASENAME0=$(basename "$0")
LOGDIR="$BASEDIR/Log"
NPARAMS=2
LOGFILE="$LOGDIR/$BASENAME0_$2_$DATETAG.log"
RESULTFILE="$LOGDIR/Result_$BASENAME0_$2_$DATETAG.log"
ficConf=$2
HorizT='├'
HLine='─'
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
## Verification du nombre de param
#################################################################
if [[ $# -lt "$NPARAMS" || $# -gt "$NPARAMS" ]]
   then
       echo "ce script a besoin de $minparams arguments en entree!"
       echo "Liste des arguments passes en paramètre : $@"
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
## Recup des params de generation en fonction des infos du fichier de conf : form_gen.conf
#################################################################
nbAlgo=$(($(readlineval $ficConf 2) - 1))
nbAlgoHyperparamVal=$(($(readlineval $ficConf 3) - 1))
nbDataset=$(($(readlineval $ficConf 4) - 1))
nbDatasetShape=$(($(readlineval $ficConf 5) - 1))
datasetInferenceProperties=$(($(readlineval $ficConf 6) - 1))
nbMeasures=$(($(readlineval $ficConf 7) - 1))
infraComponents=$(($(readlineval $ficConf 8) - 1))

#################################################################
## Declaration dans le fichier de formulaire des param qui ont servi a generer ce formulaire 
## ATTENTION : Ces infos seront reprises pour la transformation en JSON grace a form2json.sh 
#################################################################
echo "[Config]  # NE PAS MODIFIER"
echo " ├nbAlgo=$nbAlgo                                              #Nombre occurences objet Algorithm dans le formulaire"
echo " ├nbAlgoHyperparamVal=$nbAlgoHyperparamVal                    #Nombre occurences object Hyperparameter Value par Algorithm dans le formulaire"
echo " ├nbDataset=$nbDataset                                        #Nombre occurences object Dataset dans le formulaire"
echo " ├nbDatasetShape=$nbDatasetShape                              #Nombre occurences object Shape par Dataset dans le formulaire"
echo " ├datasetInferenceProperties=$datasetInferenceProperties      #Nombre occurences object InferenceProperties par Dataset dans le formulaire"
echo " ├nbMeasures=$nbMeasures                                      #Nombre occurences object Measures dans le formulaire"
echo " ├infraComponents=$infraComponents                            #Nombre occurences object Components dans le formulaire"
echo " └"

########################################## 
# On parcourt le tableau de références et on construit pour chaque ligne la bonne ligne de formulaire
#########################################
for (( refline=2; refline<=113; refline++ ))
do
    #On recupère les informations de la ligne du tableau de référence
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

    #Ici on check le cote obligatoire d une entree
    if [[ "$strMandatory" == "TRUE" ]] 
    then       
        strMandatory="MANDATORY"
    else
        strMandatory="OPTIONAL"
    fi

    #Ici en fonction du type d entree on met en forme et on genere la ligne de texte que l'on envoie a la fonction d ecriture de ligne
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
            if [[ $strName = "quality" ]] 
            then
                inputtmp="$strQuestion="
                commenttmp="#$strMandatory value in {$strEnum} : $strComment"
                write_line "$strMandatory" "$inputtmp" "$commenttmp" $nbtab $mode  
            else
                inputtmp=" $startChar$strQuestion="
                commenttmp="#$strMandatory value in {$strEnum} : $strComment"
                write_line "$strMandatory" "$inputtmp" "$commenttmp" $nbtab $mode  
            fi
            ;;
            
        "String")
            inputtmp=" $startChar$strQuestion="
            commenttmp="#$strMandatory as {$strType} : $strComment"
            write_line "$strMandatory" "$inputtmp" "$commenttmp" $nbtab $mode  
            ;;
            
        "Integer")
            inputtmp=" $startChar$strQuestion="
            commenttmp="#$strMandatory as {$strType} : $strComment"
            write_line "$strMandatory" "$inputtmp" "$commenttmp" $nbtab $mode  
            ;;

        "Float")
            inputtmp=" $startChar$strQuestion="
            commenttmp="#$strMandatory as {$strType} : $strComment"
            write_line "$strMandatory" "$inputtmp" "$commenttmp" $nbtab $mode  
            ;;
        
        "Boolean")
            inputtmp=" $startChar$strQuestion="
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

            unset IFS # or set back to original IFS if previously set
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

            #ici pour permettre de generer un nombre d'occurence de certains objets on capte la position dans le tableau du debut de l'objet
            if [[ $strName == "algorithms End" ]]; then nbIter=$nbAlgo ; fi
            if [[ $strName == "values End" ]]; then nbIter=$nbAlgoHyperparamVal ; fi
            if [[ $strName == "shape End" ]]; then nbIter=$nbDatasetShape ; fi
            if [[ $strName == "inferenceProperties End" ]]; then nbIter=$datasetInferenceProperties ; fi
            if [[ $strName == "components End" ]]; then nbIter=$infraComponents ; fi
            if [[ $strName == "dataset End" ]]; then nbIter=$nbDataset ; fi
            if [[ $strName == "measures End" ]]; then nbIter=$nbMeasures ; fi

            #Ici en fonction du nombre d occurence on iter dans le tableau de param pour ecrire plusieurs tables
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

            array=("hyperparameters End${IFS}parametersNLP End")
            isInArray="$strName"

            if [[ "${IFS}${array[*]}${IFS}" =~ "${IFS}${isInArray}${IFS}" ]]; then
                if [ $nbtab -gt 0 ]; then let "nbtab--" ; fi
            fi
            ;;

    esac

done
