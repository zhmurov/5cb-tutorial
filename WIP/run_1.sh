 #!/bin/bash

## Set variables
GMX=/usr/local/gromacs/bin/gmx
PACKMOL=~/git/external/packmol/packmol

PATH_TO_FILES=~/git/artemzhmurov/5cb-tutorial/WIP/1
TRAPPEUAFFHOME=~/git/external/trappeua

mkdir tmp
cd tmp

name="5CB"

# Create folder for the molecular system
mkdir ${name}
cd ${name}
cp -r ${TRAPPEUAFFHOME}/trappeua.ff .

# Copy and preapre packmol input
cp ${PATH_TO_FILES}/* .

cp ../trappeua.ff/liquidcrystals/5CB.gro conf.gro

$GMX editconf -f conf.gro -o conf.gro -box 200 200 200
$GMX grompp -f em.mdp -c conf.gro -o em.tpr
$GMX mdrun -deffnm em -nt 1

$GMX grompp -f nvt.mdp -c em.gro -o nvt.tpr
$GMX mdrun -deffnm nvt -nt 1
$GMX grompp -f npt.mdp -c nvt.gro -o npt.tpr
$GMX mdrun -deffnm npt -nt 1

$GMX grompp -f md_iso.mdp -c npt.gro -o md_iso.tpr
$GMX mdrun -deffnm md_iso -nt 1
