# 

# variables available on command line

variable        T index 293.15      # K

# global model settings

echo               both
units              real
dimension          3
atom_style         full
boundary           p p p

pair_style         lj/cut/coul/long  12.5 
pair_modify        shift yes mix arithmetic 
kspace_style       pppm 0.00001
bond_style         harmonic
angle_style        harmonic
read_data          C39_1020water.data

# pair_coeff

pair_coeff 	1	1	0.105	3.851
pair_coeff 	2	2	0.06	3.5
pair_coeff 	3	3	0.06	3.5
pair_coeff 	4	4	0.105	3.851
pair_coeff 	5	5	0.069	3.66
pair_coeff 	6	6	0.105	3.851
pair_coeff 	7	7	0.105	3.851
pair_coeff 	8	8	0.06	3.5
pair_coeff 	9	9	0.06	3.5
pair_coeff 	10	10	0.105	3.851
pair_coeff 	11	11	0.105	3.851
pair_coeff 	12	12	0.274	4.035
pair_coeff 	13	13	0.044	2.886
pair_coeff 	14	14	0.044	2.886
pair_coeff 	15	15	0.044	2.886

pair_coeff      16 16 0.15535 3.166
pair_coeff      17 17 0.0000 0.0000       

# pair_coeff 	18	18    0.072896 2.958

# define groups
molecule        h2omol H2O.txt
group              wall  type < 16 
group              h2o type 16 17
# group		      ggcmc type 18

neighbor          2.0 bin
neigh_modify      every 1 delay 1 check yes  exclude group wall wall 

#MD settings

fix               1  wall nve/noforce  # move linear 0 0 0
fix               mynvt h2o nvt temp ${T} ${T} 100
fix               wshake h2o shake 0.0001 50 0 b 1 a 1 mol h2omol
            
thermo            1000
thermo_style      custom step pe ke atoms 

run               1000000

write_data        C39_1020waternvt1ns.data




