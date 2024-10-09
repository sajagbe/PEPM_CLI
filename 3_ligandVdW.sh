python2.7 -m pip install virtualenv >> main.log
python2.7 -m virtualenv vdw_surface >> main.log 
source vdw_surface/bin/activate >> main.log 
python -m pip install cython >> main.log 
cd vdw_surface 
git clone https://github.com/rmcgibbo/pyvdwsurface.git >> main.log
cd pyvdwsurface     
python -m pip install . >> main.log
python -m pip install matplotlib numpy >> main.log


cd ../../



while read -r line; do
    ligand=$(echo $line | awk '{print $1}')
    python 3I_vdwSurface.py $ligand.xyz >> main.log
    mv points.txt ${ligand}_points
done < Ligand_list.txt

deactivate
