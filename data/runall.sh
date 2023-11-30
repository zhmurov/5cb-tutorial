 #!/bin/bash

## Set variables
GMX=/usr/local/gromacs/bin/gmx

mkdir sim
cd sim

# Create folder for the molecular system
git clone https://github.com/zhmurov/trappeua
mv trappeua/trappeua.ff .
rm -rf trappeua

# Clone the repo with packmol and run it
git clone https://github.com/m3g/packmol.git
cd packmol
git checkout v20.3.5
./configure
make
cd ..

packmol/packmol < ../input/packmol.inp

# Copy the topology file
cp ../input/topol.top .

$GMX editconf -f conf.pdb -o conf.gro -box 4 4 4
$GMX grompp -f ../input/em.mdp -c conf.gro -o em.tpr
$GMX mdrun -deffnm em -v

$GMX grompp -f ../input/nvt.mdp -c em.gro -o nvt.tpr
$GMX mdrun -deffnm nvt -v
$GMX grompp -f ../input/npt.mdp -c nvt.gro -o npt.tpr
$GMX mdrun -deffnm npt -v

ELECTRIC_FIELDS="0.00 0.01 0.10 0.20 0.50 1.0 2.0 5.0 10.0 50.0"

for ELECTRIC_FIELD in $ELECTRIC_FIELDS; do

    cp ../input/md_iso_E.mdp md_iso_${ELECTRIC_FIELD}.mdp
    sed -i "s/ELECTRIC_FIELD/${ELECTRIC_FIELD}/g" md_iso_${ELECTRIC_FIELD}.mdp

    $GMX grompp -f md_iso_${ELECTRIC_FIELD}.mdp -c npt.gro -o md_iso_${ELECTRIC_FIELD}.tpr
    $GMX mdrun -deffnm md_iso_${ELECTRIC_FIELD} -v
    
done
