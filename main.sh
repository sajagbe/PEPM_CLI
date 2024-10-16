echo ""
echo " "
echo "What pdb file would you like to plot a PEPM for?"
echo ""
read pdbName


./1_pdb2dx.sh << SOA >> main.log
$pdbName
A
SOA
 
./2_dx2mol2.sh << SOA >> main.log
$pdbName.dx
SOA


./3_ligandVdW.sh >> main.log



./4_surfaceCharges.sh >> main.log



rm -rf Ligand_list* lig*_points lig*_point_charges.txt pdb2dx vdw_surface p3
mkdir ${pdbName}_PEPM

mv pdb2dx.log *_autoPEPM.mol2 lig*.xyz ${pdbName}Grid* ${pdbName}.* ${pdbName}_PEPM





