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
mkdir ${name}_100
cd ${name}_100
cp -r ${TRAPPEUAFFHOME}/trappeua.ff .

# Copy and preapre packmol input
cp ${PETROLMD}/5CBTraPPE-UA/100/* .

$PACKMOL < packmol.inp

$GMX editconf -f conf.pdb -o conf.gro -box 4 4 4
$GMX grompp -f em.mdp -c conf.gro -o em.tpr
$GMX mdrun -deffnm em

$GMX grompp -f nvt.mdp -c em.gro -o nvt.tpr -maxwarn 1
$GMX mdrun -deffnm nvt
$GMX grompp -f npt.mdp -c nvt.gro -o npt.tpr -maxwarn 1
$GMX mdrun -deffnm npt

$GMX grompp -f md_iso.mdp -c npt.gro -o md_iso.tpr -maxwarn 1
$GMX mdrun -deffnm md_iso
