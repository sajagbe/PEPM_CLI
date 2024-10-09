echo "
    Installing dependencies
"


python -m pip install numpy
 
echo "
    What dx do you want to convert?
"
read inputFile

inputFileName="${inputFile%.*}"

# Function to convert scientific notation to decimal
sci_to_decimal() {
    printf "%.6f" $1
}

# Extract origin coordinates

gridNumber=$(grep gridpositions $inputFile | awk '{print $NF}')
tempSpacing=$(grep -i -m 1 "delta" $inputFile | awk '{print $2}')

temp_x=$(grep "origin" $inputFile | awk '{print $2}')
temp_y=$(grep "origin" $inputFile | awk '{print $3}')
temp_z=$(grep "origin" $inputFile | awk '{print $4}')

origin_x=$(sci_to_decimal $temp_x)
origin_y=$(sci_to_decimal $temp_y)
origin_z=$(sci_to_decimal $temp_z)

gridSpacing=$(sci_to_decimal $tempSpacing)
noOfgridItems=$(($gridNumber ** 3))
plus2=$((noOfgridItems + 2))

# Print origin coordinates
echo "origin x = $origin_x"
echo "origin y = $origin_y"
echo "origin z = $origin_z"


# Print grid Spacing and No of Grid Items
echo "gridSpacing = $gridSpacing"
echo "Grid Items = $noOfgridItems"


# Extract and print numbers between "data follows" and 'attribute "dep" string "positions"'
# echo "Numbers in scientific notation:"
sed -n '/data follows/,/attribute "dep" string "positions"/p' $inputFile | 
    sed '1d;$d' | 
    tr ' ' '\n' | 
    grep -v '^$' | 
    awk '{printf "%.6f\n", $1}' > inputFileNameCharges

python3 2I_dx2grid.py "$origin_x" "$origin_y" "$origin_z" "$gridNumber" "$gridSpacing" > gridTemp

# column -t gridTemp > gridTmp

paste gridTemp inputFileNameCharges > finalTmp

cat << EOT > ${inputFileName}Grid.mol2
@<TRIPOS>MOLECULE
$inputFileName.mol2
 $noOfgridItems 0 0 0
SMALL
GASTEIGER

@<TRIPOS>ATOM
EOT

cat finalTmp >> ${inputFileName}Grid.mol2
paste gridTemp inputFileNameCharges > finalTmp

cat << EOT > ${inputFileName}Grid.mol2
@<TRIPOS>MOLECULE
$inputFileName.mol2
 $noOfgridItems 0 0 0
SMALL
GASTEIGER

@<TRIPOS>ATOM
EOT

cat finalTmp >> ${inputFileName}Grid.mol2


rm gridTemp finalTmp inputFileNameCharges 

awk '/@<TRIPOS>ATOM/{f=1;next} f{print $3, $4, $5, $NF}' ${inputFileName}Grid.mol2 > GridParameters
