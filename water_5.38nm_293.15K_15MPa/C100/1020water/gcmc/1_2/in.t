# 

# variables available on command line

variable        T index 293.15      # K
variable        P index 15     # MPa
variable	    fe index 1.0948
variable        Patm equal ${P}/0.101325       # atm

# global model settings

echo               both
units              real
dimension          3
atom_style         full
boundary           p p p

pair_style         lj/cut/coul/long  12.5 
pair_modify        shift yes mix arithmetic 
kspace_style       pppm 0.0001
bond_style         harmonic
angle_style        harmonic
read_data         C100_H2_1020watergcmc1ns.data

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

pair_coeff      17 17 0.15535 3.166
pair_coeff      18 18 0.0000 0.0000       

pair_coeff 	19	19    0.072896 2.958

# region
region            soall  block  EDGE EDGE EDGE EDGE -20  20 units box side in 
region            subbulk  block  EDGE EDGE EDGE EDGE -16.25  16.25 units box side in 

# define groups
molecule        h2omol H2O.txt
group              h2o type 17 18
group             wall  type < 17 
group		      ggcmc type 19

variable 	      type19 atom "type==19"
group 	            type19 dynamic ggcmc var type19
variable          nH2 equal count(type19)
group             bH2 dynamic ggcmc region subbulk every 100
variable          nbH2 equal count(bH2)

compute           mtem type19 temp/com
compute           mwtem h2o temp/com
compute_modify    mtem dynamic/dof yes

neighbor          2.0 bin
neigh_modify      every 10 delay 0 check yes  exclude group wall wall 

fix               1  wall nve/noforce  # move linear 0 0 0
fix               2 ggcmc gcmc 100 100 100 19 29494  ${T} 1 0.5 region soall pressure ${Patm} fugacity_coeff ${fe} group ggcmc
fix               mynvt h2o nvt temp ${T} ${T} 100
fix_modify        mynvt temp mwtem
fix               wshake h2o shake 0.0001 50 0 b 1 a 1 mol h2omol
fix               3 type19 nvt temp ${T}  ${T}  100 
fix_modify        3 temp mtem

thermo            1000
thermo_style      custom step c_mtem c_mwtem  pe ke atoms v_nH2 v_nbH2      

run               100000
write_data        C100_H2_1020watergcmc1.1ns.data
run               200000
write_data        C100_H2_1020watergcmc1.3ns.data
run               200000
write_data        C100_H2_1020watergcmc1.5ns.data
run               200000
write_data        C100_H2_1020watergcmc1.7ns.data
run               300000
write_data        C100_H2_1020watergcmc2ns.data




