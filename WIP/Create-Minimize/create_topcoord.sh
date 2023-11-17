#!/bin/bash

# Set variables
GMX=/usr/local/gromacs/bin/gmx
SYSTEM_NAME=5CB
PATH_TO_FILES=~/git/artemzhmurov/5cb-tutorial/WIP/Create-Minimize
FORCEFIELD_HOME=~/git/external/trappeua

mkdir tmp
cd tmp

mkdir output

cp -r ${FORCEFIELD_HOME}/trappeua.ff .

cp ${PATH_TO_FILES}/5CB.gro .

name=${SYSTEM_NAME}

# Create topology and minimize the structure
cp ${PATH_TO_FILES}em_vac.mdp em.mdp

# Make a topology for the molecule
$GMX pdb2gmx -f ${name}.gro -o ${name}.gro -p ${name}.top -ff trappeua -water tip4p

# Create a copy of the topology that can be included
cp ${name}.top ${name}.itp
# Remove the header
sed -i -n '/\[ moleculetype \]/,$p' ${name}.itp
# Remove pairs section (needed by TraPPE forcefield)
if grep -Fxq "[ pairs ]" ${name}.itp
then
    sed -i -n '1,/pairs/p;/angles/,$p' ${name}.itp
    sed -i '\[ pairs \]/d' ${name}.itp
else
    echo "Skipping ${name}.itp"
fi
# Remove the footer
sed -i '/; Include Position restraint file/,$d' ${name}.itp
# Rename the molecule
sed -i "s/Other/${name}/g" ${name}.itp

# Create topology that include itp file we just created
cp ${name}.top ${name}_bck.top
cp ${PATH_TO_FILES}/template.top ${name}.top
sed -i "s/NEWMOLECULENAME/${name}/g" ${name}.top

$GMX editconf -f ${name}.gro -o ${name}.gro -d 0.1
$GMX editconf -f ${name}.gro -o ${name}.gro -box 100 100 100 -noc
$GMX grompp -f em.mdp -c ${name}.gro -p ${name}.top -o ${name}_em.tpr
$GMX mdrun -deffnm ${name}_em

cp ${name}_em.gro output/${name}.gro
$GMX editconf -f ${name}_em.gro -o ${name}_em.pdb
cp ${name}_em.pdb output/${name}.pdb

