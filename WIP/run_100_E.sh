 #!/bin/bash

## Set variables
GMX=/usr/local/gromacs/bin/gmx
PACKMOL=~/git/external/packmol/packmol

PETROLMD=~/git/artemzhmurov/petrolmd
TRAPPEUAFFHOME=~/git/external/trappeua

mkdir tmp
cd tmp

name="5CB"

# Create folder for the molecular system
mkdir ${name}_100_E
cd ${name}_100_E
cp -r ${TRAPPEUAFFHOME}/trappeua.ff .

# Copy and preapre packmol input
cp ${PETROLMD}/5CBTraPPE-UA/100/* .

$PACKMOL < packmol.inp

$GMX editconf -f conf.pdb -o conf.gro -box 4 4 4
$GMX grompp -f em.mdp -c conf.gro -o em.tpr
$GMX mdrun -deffnm em -nt 2

$GMX grompp -f nvt.mdp -c em.gro -o nvt.tpr
$GMX mdrun -deffnm nvt -nt 2
$GMX grompp -f npt.mdp -c nvt.gro -o npt.tpr
$GMX mdrun -deffnm npt -nt 2

ELECTRIC_FIELDS="0.01 0.1 1.0 10.0"

for ELECTRIC_FIELD in $ELECTRIC_FIELDS; do

    cp md_iso_E.mdp md_iso_${ELECTRIC_FIELD}.mdp
    sed -i "s/ELECTRIC_FIELD/${ELECTRIC_FIELD}/g" md_iso_${ELECTRIC_FIELD}.mdp

    $GMX grompp -f md_iso_${ELECTRIC_FIELD}.mdp -c npt.gro -o md_iso_${ELECTRIC_FIELD}.tpr
    $GMX mdrun -deffnm md_iso_${ELECTRIC_FIELD} -nt 2
    
done
