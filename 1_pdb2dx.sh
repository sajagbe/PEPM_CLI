
echo ""
echo " "
echo "What pdb file would you like to plot a PEPM for?"
echo ""
read pdbName

#sudo port selfupdate && sudo port install apbs > /dev/null 2>&1

#Download PDB from Protein Data Bank
wget https://files.rcsb.org/download/$pdbName.pdb

if [[ ! -f $pdbName.pdb ]];
then 
   echo ""
   echo "PDB file not found."
   echo ""
   echo "Please download manually."
   echo ""
   exit 0
fi

echo  ""
echo "            Found and Downloaded $pdbName.pdb " 


rm -r ${pdbName}_PEPM md.log > /dev/null 2>&1


# mv $pdbName.pdb ${pdbName}_PEPM && cd ${pdbName}_PEPM

#Remove all Header and Footer Lines
awk '{ if ($1 == "ATOM") { print } else if ($1 == "TER") { print } else if ($1 == "HETATM"){print}}' $pdbName.pdb > ${pdbName}Clean.pdb
rm $pdbName.pdb && mv ${pdbName}Clean.pdb ${pdbName}.pdb

Chains=()

while read p; do 
      chain=`echo "$p" | awk -vFS="" '{print $22}'`
      if [[ "${Chains[@]}" =~ $chain ]]; then
               :
      else
         # echo "Nuh Huh"
         Chains+=("$chain")
      fi

      # echo "${Chains[*]}"
done < $pdbName.pdb

NoOfChains=${#Chains[@]}

if (( $NoOfChains > 0 )); then
   echo "
   
   "

   echo This protein has $NoOfChains chain[s]: 
   for key in "${!Chains[@]}"
   do
      echo "$(( $key + 1 )): ${Chains[$key]}"
   done

   if [ $NoOfChains -eq 1 ] ; then
        echo "
   
            "
         echo "I will use chain A."
         egrep "^.{21}A" $pdbName.pdb > ${pdbName}Monomer.pdb
   else
      echo "
      Which would you like to use? (Enter Alphabet)
      "
      read input

      ChainChoice=`echo $input | awk '{print toupper($0)}'`
      # echo $ChainChoice

      if [[ "${Chains[@]}" =~ $ChainChoice ]]; then
         egrep "^.{21}$ChainChoice" $pdbName.pdb > ${pdbName}Monomer.pdb
      else
         exit
      fi


   fi
fi

rm $pdbName.pdb  && mv ${pdbName}Monomer.pdb $pdbName.pdb



#Find and Remove water oxygens
grep -E "HOH" ${pdbName}.pdb | grep "HETATM" | awk '{print}' > water.xyz 
grep -vf water.xyz ${pdbName}.pdb > ${pdbName}Dry.pdb
rm $pdbName.pdb water.xyz && mv ${pdbName}Dry.pdb ${pdbName}.pdb


#Remove Double Atom Configs
awk '{ if(substr($0, 17, 1) != "B") print }' ${pdbName}.pdb > temp && mv temp ${pdbName}.pdb
awk 'BEGIN{FS=OFS=""} {sub(".", " ", $17)} 1' ${pdbName}.pdb > temp && mv temp ${pdbName}.pdb


#Remove Ligands
grep -E "HETATM" ${pdbName}.pdb | awk '{print}' > Ligands.pdb 
grep -vf Ligands.pdb ${pdbName}.pdb > ${pdbName}Sauceless.pdb
mv ${pdbName}Sauceless.pdb ${pdbName}.pdb


#Separate ligands
input_file="Ligands.pdb"  

awk '
{
    if ($4 != prev_value) {
        if (output_file) {
            close(output_file)
        }
        output_file = "lig" $4
        prev_value = $4
    }
    print > output_file
}' "$input_file"


#Convert protein pdb to pqr & Protonate at pH-7
pdb2pqr --ff=AMBER --with-ph=7.0 $pdbName.pdb $pdbName.pqr > /dev/null 2>&1


#Save all ligands to list
find . -maxdepth 1 -type f -name "lig*" | sed 's|^\./||' > Ligand_list.txt



input_file="Ligand_list.txt"

# Check if the file exists
if [ ! -f "$input_file" ]; then
    echo "Error: File $input_file not found."
    exit 1
fi

while IFS= read -r line
do
    # Save the line as a variable
    current_row="$line"

    echo "
    
    Processing: $current_row"
    mv $current_row $current_row.pdb
    obabel -ipdb $current_row.pdb -oxyz -O$current_row.xyz
    # Empty the second line comment in the xyz file
    sed '2s/.*//g' "$current_row.xyz" > temp.xyz && mv temp.xyz "$current_row.xyz"
    rm $current_row.pdb

done < "$input_file"


echo "
read
mol pqr ${pdbName}.pqr
end

elec
mg-auto
dime 129 129 129
cglen 80 80 80
fglen 64 64 64
cgcent mol 1
fgcent mol 1
mol 1
lpbe
bcfl sdh
pdie 2.0
sdie 78.54
srfm smol
chgm spl2
sdens 10.0
srad 1.4
swin 0.3
temp 298.15
calcenergy total
calcforce no
write pot dx ${pdbName}
end

quit" > apbs.in

apbs apbs.in > /dev/null 2>&1

rm $pdbName.pdb $pdbName.log apbs.in io.mc Ligands.pdb

echo "

*******************************************************************************

  To make a PEPM plot, use ${pdbName}.dx and the pqr for the Ligand of Interest
 
********************************************************************************
"
