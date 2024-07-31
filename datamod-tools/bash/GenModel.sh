#!/bin/bash

##########################################
# Script de Generation et mise au format du datamodel AI power
# Author : dfovet
# Version : 0.1
# Date : 20240731
#########################################

##########################################
# Init des variables
#########################################
DATETAG=`date +%y%m%d-%H%M`
BASEDIR=$(pwd)
BASENAME0=$(basename "$0")
LOGDIR="$BASEDIR/Log"
CONFDIR="$BASEDIR/Config"
NPARAMS=2
FICPARAM="$BASENAME0.param"
LOGFILE="$LOGDIR/$BASENAME0_$DATETAG.log"

##########################################
# Gestion de Log
#########################################
tolog()
{
LOGTIMETAG=`date +%Y\;%m\;%d\;%H\;%M\;%S\;%N`
echo "$LOGTIMETAG--$1" >> $2
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
# Usage et check du nombre de params
#########################################
usage()
{
echo "-----------------------------------------------------"
echo "Mauvais Usage ATTENTION"
echo "-----------------------------------------------------"
echo "But du script : Générer un model de données ai power measurment viable"
echo ""
echo "Scructure de la commande : "
echo "GenModel.sh <option> <fichier de model json>"
echo "<option>"
echo " init : Pour initialiser l'ensemble du model"
echo " delta : Pour ne remplir que ce qui est manquant"
echo "<fichier de model json>"
echo " Si init : Nom du fichier json qui sera crée"
echo " Si delta : Nom du fichier json a completer"
}

if [[ $# -lt "$NPARAMS" || $# -gt "$NPARAMS" ]]
   then
       echo "ERROR : Ce script a besoin de $NPARAMS arguments en entree!"
       echo "Liste des arguments passes en paramètre : $@"
       usage
exit 0
fi

#################################################################
## Recuperation parametres a partir du fichier de parametres
#################################################################
tolog "Recuperation parametres a partir du fichier de parametres" $LOGFILE
if [[ -n "$FICPARAM" ]]
then
        . $FICPARAM
else
        echo "Fichier de properties manquant ou incorrect"
fi

################################################################
# initialisation du fichier de log si non crée
################################################################
tolog "Initialisation du fichier de log si non crée" $LOGFILE
if [[ -n "$LOGFILE" ]]
then
        echo "$LOGFILE => Déja initialisé"
        tolog "$LOGFILE => Déja initialisé" $LOGFILE
else
        touch $LOGFILE
        echo "$LOGFILE => Initialisé"
        tolog "$LOGFILE => Initialisé" $LOGFILE
fi

##################################################################
### Selection du mode d'execution
##################################################################
#case $2 in 
#	A)
#		T="Y"
#		P="Y"
#		;;
#	T)
#		T="Y"
#		;;
#	P)
#		P="Y"
#		;;
#	*)
#		echo "BAD Argument : $2"
#esac
#
tolog "Debut de generation du json" $LOGFILE

##########################################
# Utiliser : Lire dans un fichier tableau separé par des ; 
# readtab <Fichier tableau> <colonne number> <ligne number>
#########################################
toto=$(readtab $CONFDIR/header.param 2 2)
echo $toto

tolog "Fin de generation du json" $LOGFILE