# Project Phase 1
# Task 1
# AMPL Model
# Andrew Torres, Francine Kibwana, Denise Sullivan, Ted Hall

# number buses in case

# define sets
set BUSES;
set BRANCHES within (BUSES cross BUSES cross BUSES); 
set GENERATORS within  (BUSES cross BUSES); 

# define parameters
param demand{BUSES} default 0;  
param reactance{BRANCHES}; 
param lower_line_limit{BRANCHES};
param upper_line_limit{BRANCHES};
param pg_cost{GENERATORS};                        
param pg_max{GENERATORS};
param pg_min{GENERATORS};
param alpha{GENERATORS}; 

# define variables
var pg{GENERATORS}  >= 0;
var pd{GENERATORS}  >= 0;
var delta{BUSES} >= 0;

# objective function
minimize total_cost: 
  sum{(i,j) in GENERATORS} pg[i,j] * pg_cost[i,j];

# constraints

# subject to balance{i in GENERATORS}:
#  sum{(i,j) in BRANCHES} pg[i,j]-pd[j] = sum{(i,j,k) in BRANCHES} pg[j,i] - pd[i,j,k];

subject to balance{i in BUSES}:
sum{(i,m) in GENERATORS} pg[i,m] + sum{(j,i,k) in BRANCHES}((1/reactance[j,i,k]) * (delta[j] - delta[i])) 
= sum{(i,j,k) in BRANCHES}((1/reactance [i,j,k]) * (delta[i] - delta[j])) + demand[i] + sum{(i,m) in GENERATORS} pd[i,m];

subject to minimum{(i,m) in GENERATORS}:
pg[i,m] >= pg_min[i,m];

subject to maximum{(i,m) in GENERATORS}:
pg[i,m] <= pg_max[i,m];

subject to low_line_limit{(i,j,k) in BRANCHES}:
(1/ reactance [i,j,k]) * (delta[i] - delta[j]) >= lower_line_limit[i,j,k];

subject to  up_line_limit{(i,j,k) in BRANCHES}:
(1 / reactance [i,j,k]) * (delta[i] - delta[j]) <= upper_line_limit[i,j,k];
