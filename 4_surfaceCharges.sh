pip install virtualenv > /dev/null 2>&1
virtualenv p3
source p3/bin/activate

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 
brew install -f python3
python3 -m pip install scipy numpy >> main.log



while read -r line; do
    ligand=$(echo $line | awk '{print $1}')
    python3 4I_chargeSearch.py GridParameters ${ligand}_points
    mv point_charges.txt ${ligand}_point_charges.txt

     # Get the length of the point charges file
     pc_length=$(wc -l < ${ligand}_point_charges.txt)

     rm tempNumAtoms tempAtomType check > /dev/null 2>&1

    # Add content to the temporary file
    for ((i=1; i<=$pc_length; i++)); do
        echo "$i C" >> "tempNumAtoms"
        echo "C3 1 XXX129" >> "tempAtomType"
    done


cat << EOF > ${ligand}_autoPEPM.mol2
@<TRIPOS>MOLECULE
${ligand}.mol2
${pc_length} 0 0 0
SMALL
GASTEIGER
@<TRIPOS>ATOM       
EOF

paste tempNumAtoms ${ligand}_points tempAtomType ${ligand}_point_charges.txt > check
column -t check > temp && mv temp check
cat check >> ${ligand}_autoPEPM.mol2
 
done < Ligand_list.txt

rm ${ligand}_points ${ligand}_point_charges.txt tempNumAtoms tempAtomType chec* GridParameters  

deactivate