#!/bin/bash

##########################################
# Script de Generation de formulaire texte pour le datamodel Boamps
# Author : dfovet
# Version : 0.76
# Date : 20250609
#########################################

##########################################
# Usage
#########################################
usage()
{
echo "-----------------------------------------------------"
echo "Mauvais Usage ATTENTION"
echo "-----------------------------------------------------"
echo "But du script : Generer un formulaire pour le modele de donnees ai power measurement"
echo ""
echo "Structure de la commande : "
echo "./gen_form.sh <Type de generation> <CSV de reference> <Fichier de parametres> <Nom du fichier d'entrée> <Numero de ligne du fichier d'entrée a integrer>"
echo "example1 : ./gen_form.sh -a Ref_CodeCarbon.csv CodeCarbonCSV.conf > report1.txt"
echo "example2 : ./gen_form.sh -a Ref_CodeCarbon.csv CodeCarbonCSV.conf emissions.csv 2 > report-codecarbon-prefill.txt"
echo "<Type de generation>"
echo " -a pour ALL genere un formulaire incluant les champs obligatoires et facultatifs"
echo "<CSV de reference>"
echo "Fichier descriptif du model de données incluant ou non les references pour remplir le formulaire a partir d'un CSV "
echo "Exemple : Ref_CodeCarbon.csv Pour préremplir dans le formulaire a partir d'un csv CodeCarbon"
echo "<Fichier de parametres>"
echo "Fichier permetant de moduler le nombre de section dans le formulaire"
echo "<Nom du fichier d'entrée>"
echo "Fichier d'entrée au format csv qui contient les resultats des tests Green AI Initiative "
echo "<Numero de ligne du fichier d'entrée a integrer>"
echo "Le numero de la ligne contenant le resultat a convertir au format boamps"
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
# Lire dans un fichier tableau séparé par des ,
#########################################
readtab2()
{
    i=$2
    j=$3
    RES=""
    RES=$(sed -n ''$j','$j' p' $1 | awk -v idx=$i -F',' '{print $idx}')
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
# Lire dans un fichier tableau séparé par des ; trouver une certaine colonne en fonction de son nom et prendre la valeur de la ligne demandé
#gettabcolval $inputcsv $strCmd $ligneinput $nbentry
#########################################
gettabcolval()
{
  csvfile=$1
  test=$2
  rowc=$3 #min=2 because 1 mean the head of csv
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
        val=$(readtab2 $csvfile $i 1)
        #echo $val #Debug pour la valeur de la colonne
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
          val=$(readtab2 $csvfile $j $rowc)
          echo $val
        fi
      fi
    fi
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
NPARAMSMAX=5
LOGFILE="$LOGDIR/$BASENAME0_$2_$DATETAG.log"
RESULTFILE="$LOGDIR/Result_$BASENAME0_$2_$DATETAG.log"
ficRef=$2
ficConf=$3
inputcsv=$4
ligneinput=$5
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
## Verification du nombre de param
#################################################################
if [[ $# -lt "$NPARAMS" ]] || [[ $# -gt "$NPARAMSMAX" ]]
   then
       echo "ce script a besoin de $NPARAMS arguments en entree!"
       echo "Nombre de param : $#"
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
nbAlgo=$(($(readlineval $ficConf 2) ))
nbAlgoHyperparamVal=$(($(readlineval $ficConf 3) ))
nbDataset=$(($(readlineval $ficConf 4) ))
nbDatasetShape=$(($(readlineval $ficConf 5) ))
datasetInferenceProperties=$(($(readlineval $ficConf 6) ))
nbMeasures=$(($(readlineval $ficConf 7) ))
infraComponents=$(($(readlineval $ficConf 8) ))

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
for (( refline=2; refline<=$nbligneparam; refline++ ))
do
    #On recupère les informations de la ligne du tableau de référence
    strName=$(readtab $ficRef 4 $refline)
    strType=$(readtab $ficRef 6 $refline)
    strMandatory=$(readtab $ficRef 7 $refline)
    strCmd=$(readtab $ficRef 9 $refline)
    strEnum=$(readtab $ficRef 10 $refline)
    strQuestion=$(readtab $ficRef 12 $refline)
    strComment=$(readtab $ficRef 13 $refline)

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
            if [[ -f $inputcsv ]]
            then
              valtmp=$(gettabcolval $inputcsv $strCmd $ligneinput $nbentry)
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
              valtmp=$(gettabcolval $inputcsv $strCmd $ligneinput $nbentry)
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
              valtmp=$(gettabcolval $inputcsv $strCmd $ligneinput $nbentry)
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
              valtmp=$(gettabcolval $inputcsv $strCmd $ligneinput $nbentry)
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
              valtmp=$(gettabcolval $inputcsv $strCmd $ligneinput $nbentry)
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

            array=("hyperparameters End${IFS}inferenceProperties End${IFS}parametersNLP End")
            isInArray="$strName"

            if [[ "${IFS}${array[*]}${IFS}" =~ "${IFS}${isInArray}${IFS}" ]]; then
                if [ $nbtab -gt 0 ]; then let "nbtab--" ; fi
            fi
            ;;

    esac

done
