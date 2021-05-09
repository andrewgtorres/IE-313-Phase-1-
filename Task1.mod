# Project Phase 1
# Task 1
# AMPL Model
# Andrew Torres, Francine Kibwana, Denise Sullivan, Ted Hall

# define sets
set BUSES = 1..num_buses; 
set BRANCHES within (BUSES cross BUSES cross BUSES); 
set GENERATORS within  (BUSES cross BUSES); 

# define parameters
param num_buses;
param demand{BUSES} default 0;  
param reactance{BRANCHES}; 
param lower_line_limit {BRANCHES};
param upper_line_limit {BRANCHES};
param pg_cost {GENERATORS};                        
param pg_max {GENERATORS};
param pg_min {GENERATORS};
param alpha {GENERATORS}; 

# define variables
var pg{GENERATORS}  >= 0;
var pd{GENERATORS}  >= 0;
var delta {BUSES} >= 0;

# objective function
minimize total_cost: 
  sum{(i,j) in GENERATORS} pg[i,j] * pg_cost[i,j];

# constraints

subject to balance{i in GENERATORS}:
  sum{(i,j) in BRANCHES} pg[i,j]-pd[j] = sum{(i,j,k) in BRANCHES} pg[j,i] - pd[i,j,k];

subject to balance{i in BUSES, i not in GENERATORS}:
sum{(i,j) in GENERATORS} pg[i,j]-pd[i,j] = sum{(j,i) in GENERATORS} pg[j,i,k] - pd[i,j,k];

subject to genuplim {(i,j) in GENERATORS}:
pg[i,j] <= pg_max[i,j];

subject to genlowlim {(i,j) in GENERATORS}:
pg[i,j] >= pg_min[i,j];

subject to UPPERLIMCON {(i,j,k) in BRANCHES}:

(1 / reactance [i,j,k]) * (delta[i] - delta[j]) <= upper_line_limit[i,j,k];

subject to LOWERLIMCON {(i,j,k) in BRANCHES}:
(1/ reactance [i,j,k]) * (delta[i] - delta[j]) >= lower_line_limit[i,j,k];
