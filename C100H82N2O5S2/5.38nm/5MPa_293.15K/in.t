# 

# variables available on command line

variable        T index 293.15      # K
variable        P index 5      # MPa
variable	    fe index 1.0302
variable        Patm equal ${P}/0.101325       # atm

# global model settings

echo               both
units              real
dimension          3
atom_style         atomic
boundary           p p p

read_data         C100H82N2O5S2.data
pair_style         lj/cut   12.5
pair_modify        shift yes mix arithmetic 

# pair_coeff

pair_coeff 	1	1	0.105	3.851
pair_coeff 	2	2	0.105	3.851
pair_coeff 	3	3	0.105	3.851
pair_coeff 	4	4	0.105	3.851
pair_coeff 	5	5	0.105	3.851
pair_coeff 	6	6	0.274	4.035
pair_coeff 	7	7	0.06	3.5
pair_coeff 	8	8	0.105	3.851
pair_coeff 	9	9	0.069	3.66
pair_coeff 	10	10	0.069	3.66
pair_coeff 	11	11	0.105	3.851
pair_coeff 	12	12	0.06	3.5
pair_coeff 	13	13	0.06	3.5
pair_coeff 	14	14    0.044 2.886
pair_coeff 	15	15    0.044 2.886
pair_coeff 	16	16    0.044 2.886
pair_coeff 	17	17    0.072896 2.958

# region

region            soall  block  EDGE EDGE EDGE EDGE -22  22 units box side in 

# define groups

group		      ggcmc type 17
group             wall  type < 17 

neighbor          2.0 bin
neigh_modify      every 1 delay 1 check yes  exclude group wall wall 

#MD settings

variable 	      type17 atom "type==17"
group 	            type17 dynamic ggcmc var type17
variable          nH2 equal count(type17)
compute           mtem type17 temp/com
compute_modify    mtem dynamic/dof yes

fix               1  wall nve/noforce  # move linear 0 0 0

# gcmc
fix               2 ggcmc gcmc 100 100 100 17 29494  ${T} 1 0.5 region soall pressure ${Patm} fugacity_coeff ${fe} group ggcmc
                          
fix               3 type17 nvt temp ${T}  ${T}  100 
fix_modify        3 temp mtem

thermo            1000
thermo_style      custom step c_mtem pe ke atoms v_nH2  

run               1000000

compute		pe ggcmc pe/atom
variable	      x atom c_pe

compute         layers ggcmc chunk/atom bin/1d z lower 0.1 units box bound z -45 45

fix		4 ggcmc ave/chunk 10 100 1000 layers v_x file profile.density
run               3000000

write_data        C100H82N2O5S2_gcmc4ns.data




