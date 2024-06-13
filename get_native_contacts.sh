#!/bin/bash

#This script reads, splits, and calculates native contacts from a multiple PDB file (n frames)
#Bugs can be reported to: apoma@ippt.pan.pl, fcofas@ippt.pan.pll, golivos@ippt.pan.pl

pdb=all.pdb
i=1

#Loop to split the frames

while read line; do
	echo "Procesing frame $i"
	echo "${line}" >> frame_${i}.pdb
	[[ ${line[0]} == END ]] && ((i++))
done < $pdb

#Loop to create directories for each frame.
for file in frame_*; do
	mkdir ${file%.pdb} && mv ${file} ${file%.pdb};
done

#Calculation of native contacts
i=1
for d in frame_*/; do
	cd $d
	pdbfixer frame_*.pdb --output=protein_H.pdb --ph=7.4 --keep-heterogens=none
	martinize2 -f protein_H.pdb -o protein_CG.top -x protein_CG.pdb -p backbone -ff martini3001 -cys auto -ignh -from amber -dssp /home/golivos/anaconda3/bin/mkdssp
	mv molecule_0.itp protein_CG.itp
	contact_map protein_H.pdb >> contact_map.out
	wget http://pomalab.ippt.pan.pl/web/gomartini/create_gomartini.py && chmod a+x create_gomartini.py
	./create_gomartini.py -s protein_CG.pdb -f contact_map.out --go_eps 12
	rm contact_map.out chain_X.ssd create_gomartini.py go_molecule1.itp go_system.gro protein_CG.itp protein_CG.pdb protein_CG.top protein_H.pdb frame_*.pdb
	input_file="go_martini.itp"
	output_file="pares_encontrados.dat"
	awk '/\[ nonbond_params \]/{found=1; next} found{print $1, $2}' "$input_file" | sed 's/GO_1_//g' > "$output_file"
	clear
	echo "Pares encontrados y guardados en $output_file en frame $i"
	i=$((i+1))
	cd ../;
done

#Concatenation of native contacts
for file in frame_*/pares_encontrados.dat; do
	cat $file >> all_contacts.dat;
done
