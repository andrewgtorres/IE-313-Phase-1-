# Project Phase 1
# Task 2
# AMPL Model
# Andrew Torres, Francine Kibwana, Denise Sullivan, Ted Hall

# number buses in case
param num_buses;

# define sets
set BUSES = 1..num_buses;
set BRANCHES within (BUSES cross BUSES cross BUSES); 
set GENERATORS within  (BUSES cross BUSES); 

# define sets for one generator and no lines with contingency
set CONT_GEN = {(80,1)};
set CONT_BRANCHES = {(0,0,0)};

# define parameters
param demand{BUSES} default 0;  
param reactance{BRANCHES}; 
param lower_line_limit{BRANCHES};
param upper_line_limit{BRANCHES};
param pg_max{GENERATORS};
param pg_min{GENERATORS};
param pg_cost{GENERATORS};                        
param alpha{GENERATORS}; 

# define variables
# adding power generated when there's contingency
var power_gen_cont{GENERATORS} >= 0;
var power_generated{GENERATORS}  >= 0;
var power_dispatched{GENERATORS}  >= 0;
var delta{BUSES} >= 0;
var omega >= 0;
# total power generated across all generators (for report)
var total_pg_cont = sum{(i,j) in GENERATORS} (power_gen_cont[i,j]+power_generated[i,j]);

# objective function
minimize total_cost:
sum{(i,j) in GENERATORS: (i,j) not in CONT_GEN} ((power_gen_cont[i,j] + power_generated[i,j]) * pg_cost[i,j]);

# constraints
subject to cont_gen{(i,m) in CONT_GEN: (i,m) not in GENERATORS}:
# contingency generator produces zero power
power_generated[i,m] + power_gen_cont[i,m] = 0;

subject to equation1{(i,m) in GENERATORS: (i,m) not in CONT_GEN}:
power_gen_cont[i,m] = power_generated[i,m] + alpha[i,m]*omega;

subject to power{i in BUSES}:
# power generated + power injected = power injected + demand + power dispatched
sum{(i,m) in GENERATORS: (i,m) not in CONT_GEN} (power_gen_cont[i,m] + power_generated[i,m]) + sum{(j,i,k) in BRANCHES: (j,i,k) not in CONT_BRANCHES}((1/reactance[j,i,k]) * (delta[j] - delta[i])) 
= sum{(i,j,k) in BRANCHES: (i,j,k) not in CONT_BRANCHES}((1/reactance [i,j,k]) * (delta[i] - delta[j])) + demand[i] + sum{(i,m) in GENERATORS: (i,m) not in CONT_GEN} power_dispatched[i,m];

subject to minimum_power{(i,m) in GENERATORS: (i,m) not in CONT_GEN}:
# power generated must be greater than or equal to minimum power generated
power_generated[i,m] + power_gen_cont[i,m] >= pg_min[i,m];

subject to maximum_power{(i,m) in GENERATORS: (i,m) not in CONT_GEN}:
# power generated must be less than maximum power generates
power_generated[i,m] + power_gen_cont[i,m] <= pg_max[i,m];

subject to low_line_limit{(i,j,k) in BRANCHES: (i,j,k) not in CONT_BRANCHES}:
# power injected at each bus must be greater than or equal to lower line limit
(1/ reactance [i,j,k]) * (delta[i] - delta[j]) >= lower_line_limit[i,j,k];

subject to  up_line_limit{(i,j,k) in BRANCHES: (i,j,k) not in CONT_BRANCHES}:
# power generated at each bus must be less than or equal to upper line limit
(1 / reactance [i,j,k]) * (delta[i] - delta[j]) <= upper_line_limit[i,j,k];
