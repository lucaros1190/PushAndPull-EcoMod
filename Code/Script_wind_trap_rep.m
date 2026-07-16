% ODE model for Bactrocera oleae
% Time varying (based on temperature)

%Initialization
clear, clc % To clear the workspace and the command function

%% PARAMETERS 
rep_efficiency = 0.07;
trap_efficiency = 0.04;
mort_trap = 0.60; 
% Wind
k_factor = 1/250; % Proportional factor wind
saturation = 5; % Wind at which there is no movement

%% PARAMETERS functions

%Growth rate (Bactrocera oleae)
 a = 4.6*(10^(-5));  %1.2*(10^(-4));
 T_l = 7.23;    %3;
 T_m = 32.2;   %30;
 m = 2.5;   %6;
%  

%Mortality rate (Bactrocera oleae)
%Eggs

k1 = 0.8660965; %0.8660965
t1 = 25; %25;
r1 = -4.5; %-4.5

%L1-L2-L3

k2 = 0.8515692; %0.8515692
t2 = 22.2953273; %22.2953273;
r2 = -4.53; %-4.53
  

%Pupae

k3 = 0.82454; %0.82454
t3 = 24.6104718; %24.6104718;
r3 = -5.9965168; %-5.9965168

%Adults

k4 = 0.6383781; %0.6383781
t4 = 24.9275845; %24.9275845;
r4 = -5.9619852; %-5.9619852

% Birth rate (Bactrocera oleae)
alpha = 7000.0;  %659.06;
gamma = 68.4;  %88.53;
lambda = 50.0;  %52.32;
delta = 7.13;  %6.06; 
tau = 25.6;  %22.87; 

% Sex ratio
s_r = 0.5;

% Mating ratio
r_remate = 0;
r_mate = 1;

% Additional parameters
N_stages = 11; % Eggs/3 larva stages/ pupa /male/ unmated female/ mated female + traps(male/ unmated female/ mated female)
N_trees = 81; %Number of tress


%% DATA

%Load additional data. 

%Temperature
load('data_pantheon_2020'); %Temperature is Temp_avg
temperature(277:288) = 15; %Temperature from 277 to 288 missing (malfunctioning of weather station)
Temp_avg = temperature(92:end); %Selecting data fromt the 1st of April
wind_direction = wind_direction(92:end);
% Average direction
M = nanmean(wind_direction);
N = nanmean(wind_speed);
wind_speed = wind_speed(92:end);
%Small temperature variation for each area
max_t = 0.2;
min_t = -0.2;
t_var = min_t + (max_t-min_t) .* rand(length(Temp_avg),N_trees);
Temp_areas = repmat(Temp_avg,N_trees,1);
Temp_areas = Temp_areas + t_var';

check = find(Temp_areas >30);
Temp_areas(check) = 29.8;

% Wind direction is degree angles with respect to the north
wind_x = wind_speed .* cosd(wind_direction);
wind_y = wind_speed .* sind(wind_direction);
w=[wind_x', wind_y'];

% Average wind direction considering speed
mean_wind_x = nanmean(wind_x);
mean_wind_y = nanmean(wind_y);
wind_dir_weighted = atan2d(mean_wind_y, mean_wind_x);
if wind_dir_weighted < 0
    wind_dir_weighted = wind_dir_weighted + 360;
end

% Computation of the wind effect (correcting factor)
w(find(abs(w)>saturation)) = 0; %If wind more than the saturation limit 0.
w(isnan(w))=0; %If there is no measurement from the weather station. Wind 0
w = w*k_factor; %Wind proportional action

% Soglia massima di volo (in m/s)
threshold = 5;

% Numero totale di time steps
total_days = length(wind_speed);  % oppure: total_days = 275;

% Giorni con vento troppo forte
blocked_days = sum(wind_speed > threshold);

% Percentuale di giorni bloccati
blocked_percent = (blocked_days / total_days) * 100;


%% Traps

trap_areas = [20,22,24,26,56,58,60,62];% Areas with a trap
rep_areas = [1:9,37:45,73:81];% Areas with a repellent
trap_time = [90:270]; % Periods when there is a trap
rep_time = [150:170,180:200];
    

% 150:170,180:200 = inizio settembre, ottobre
% 150:170,180:200,210:225 = inizio settembre, ottobre, novembre

% 1b
% trap_areas = [20,22,24,26,56,58,60,62];% Areas with a trap
% rep_areas = [1:9,37:45,73:81];% Areas with a repellent

% 2
% trap_areas = [11,13,15,17,29,31,33,35,47,49,51,53,65,67,69,71];% Areas with a trap
% rep_areas = [3:7,75:79,19,28,37,46,55,27,36,45,54,63];% Areas with a repellent

% 2b
% trap_areas = [21,23,25,39,41,43,57,59,61];% Areas with a trap
% rep_areas = [3:7,75:79,19,28,37,46,55,27,36,45,54,63];% Areas with a repellent

% 2c
% trap_areas = [11,13,15,17,29,31,33,35,47,49,51,53,65,67,69,71];% Areas with a trap
% rep_areas = [19:27,37:45,55:63];% Areas with a repellent

% 4c
% trap_areas = [1:9,37:45,73:81];% Areas with a trap                   
% rep_areas = [19:27,55:63];% Areas with a repellent  

% 5
% trap_areas = [1,11,21,31,41,51,61,71,81,9,17,25,33,49,57,65,73];% Areas with a trap                   
% rep_areas = [2:8,74:80,10,19,28,37,46,55,64,18,27,36,45,54,63,72];% Areas with a repellent 

% 6
% trap_areas = [1,3,5,7,9,73,75,77,79,81,19,37,55,27,45,63,31,33,49,51];% Areas with a trap                   
% rep_areas = [11:17,65:71,20,29,38,47,56,26,35,44,53,62];% Areas with a repellent  

% 8
% trap_areas = [2,4,6,8,38,40,42,44,74,76,78,80];% Areas with a trap                   
% rep_areas = [19:27,55:63];% Areas with a repellent  

% 4
% trap_areas = [10,12,14,16,18,37,39,41,43,45,64,66,68,70,72];% Areas with a trap                   
% rep_areas = [1:9,28:36,46:54,73:81];% Areas with a repellent  


u = zeros(N_trees,length(Temp_avg));
u(trap_areas,trap_time) = 1;

v = zeros(N_trees,length(Temp_avg));
v(rep_areas,rep_time) = 1;

z=u+v;


%% Compute rates
%Compute the rates based on temperature
 
for i = 1:N_stages
   for j = 1:N_trees
   
        G_R(i,j) = growth_rate(Temp_areas(j,1), a, T_l, T_m, m);  
        B_R(i,j) = birth_rate_suzuki(Temp_areas(j,1), alpha, gamma, lambda, delta, tau);  
        S_R(i,j) = s_r;
        R_remate(i,j) = r_remate;
        R_mate(i,j) = r_mate;
if Temp_areas(j,1) >= 11 && Temp_areas(j,1) <= 27
%if t >= 120 && t <= 150
        if i == 1
            M_R(i,j) = mortality_rate_eggs(Temp_areas(j,1), k1,t1,r1)*G_R(i,j);
        elseif ismember(i, [2, 3, 4])
            M_R(i,j) = mortality_rate_larvae(Temp_areas(j,1), k2,t2,r2)*G_R(i,j);
        elseif i == 5
            M_R(i,j) = mortality_rate_pupae(Temp_areas(j,1), k3,t3,r3)*G_R(i,j);
        elseif i >= 6 && i <= 11
            M_R(i,j) = mortality_rate_adults(Temp_areas(j,1), k4,t4,r4)*G_R(i,j);
        end
elseif Temp_areas(j,1) < 11 || Temp_areas(j,1) > 27
%if t < 120 && t > 150
         if i == 1
            M_R(i,j) = mortality_rate_eggs(Temp_areas(j,1), k1,t1,r1)*(1/10);
        elseif ismember(i, [2, 3, 4])
            M_R(i,j) = mortality_rate_larvae(Temp_areas(j,1), k2,t2,r2)*(1/10);
        elseif i == 5
            M_R(i,j) = mortality_rate_pupae(Temp_areas(j,1), k3,t3,r3)*(1/120);
        elseif i >= 6 && i <= 11
            M_R(i,j) = mortality_rate_adults(Temp_areas(j,1), k4,t4,r4)*(1/30);
        end
    end
        
    end
end


%Initialize stages
Pest_stages(1:N_stages,N_trees) = stage; % We create an array of the stage class
Pest_stages = Initialize_stages_ode(B_R,M_R,G_R,S_R,R_mate,R_remate,Pest_stages,N_trees,N_stages); %We initialize the parameters associated to each stage class

%Spatial configuration
[Adj,Adj_w,Link]=Adjency_matrix(9,9);


%% DYNAMIC MODEL

%Initial values for the variables
x = zeros((N_stages)*N_trees,1); %Number of total states

A_cont = compute_A_wind_trap_rep(N_trees,Pest_stages,N_stages,Adj,u(:,1),v(:,1),z(:,1),Adj_w,w(1,:),trap_efficiency,mort_trap,rep_efficiency);

% Discretization of the system based on the zero order holder
sysc = ss(A_cont,[],eye((N_stages)*N_trees),[]);
sysd = c2d(sysc,1,'zoh');
A_dis = sysd.A; %Discretized matrix A

%% SIMULATIONS
Simulation_time =length(Temp_avg); %Simulation lenght based on the temperature array introduced

disp('Start');
tic; 

%Plants initially infested
inif = [1:81];

%Initial conditions

ind = [((inif(1)-1)*(N_stages)+5),((inif(2)-1)*(N_stages)+5),((inif(3)-1)*(N_stages)+5),((inif(4)-1)*(N_stages)+5),((inif(5)-1)*(N_stages)+5),((inif(6)-1)*(N_stages)+5),((inif(7)-1)*(N_stages)+5),...
   ((inif(8)-1)*(N_stages)+5),((inif(9)-1)*(N_stages)+5),((inif(10)-1)*(N_stages)+5),((inif(11)-1)*(N_stages)+5),((inif(12)-1)*(N_stages)+5),((inif(13)-1)*(N_stages)+5),((inif(14)-1)*(N_stages)+5),...
   ((inif(15)-1)*(N_stages)+5),((inif(16)-1)*(N_stages)+5),((inif(17)-1)*(N_stages)+5),((inif(18)-1)*(N_stages)+5),((inif(19)-1)*(N_stages)+5),((inif(20)-1)*(N_stages)+5),((inif(21)-1)*(N_stages)+5),...
   ((inif(22)-1)*(N_stages)+5),((inif(23)-1)*(N_stages)+5),((inif(24)-1)*(N_stages)+5),((inif(25)-1)*(N_stages)+5),((inif(26)-1)*(N_stages)+5),((inif(27)-1)*(N_stages)+5),((inif(28)-1)*(N_stages)+5),...
   ((inif(29)-1)*(N_stages)+5),((inif(30)-1)*(N_stages)+5),((inif(31)-1)*(N_stages)+5),((inif(32)-1)*(N_stages)+5),((inif(33)-1)*(N_stages)+5),((inif(34)-1)*(N_stages)+5),((inif(35)-1)*(N_stages)+5),...
   ((inif(36)-1)*(N_stages)+5),((inif(37)-1)*(N_stages)+5),((inif(38)-1)*(N_stages)+5),((inif(39)-1)*(N_stages)+5),((inif(40)-1)*(N_stages)+5),((inif(41)-1)*(N_stages)+5),((inif(42)-1)*(N_stages)+5),((inif(43)-1)*(N_stages)+5),...
   ((inif(44)-1)*(N_stages)+5),((inif(45)-1)*(N_stages)+5),((inif(46)-1)*(N_stages)+5),((inif(47)-1)*(N_stages)+5),((inif(48)-1)*(N_stages)+5),((inif(49)-1)*(N_stages)+5),((inif(50)-1)*(N_stages)+5),...
   ((inif(51)-1)*(N_stages)+5),((inif(52)-1)*(N_stages)+5),((inif(53)-1)*(N_stages)+5),((inif(54)-1)*(N_stages)+5),((inif(55)-1)*(N_stages)+5),((inif(56)-1)*(N_stages)+5),((inif(57)-1)*(N_stages)+5),...
   ((inif(58)-1)*(N_stages)+5),((inif(59)-1)*(N_stages)+5),((inif(60)-1)*(N_stages)+5),((inif(61)-1)*(N_stages)+5),((inif(62)-1)*(N_stages)+5),((inif(63)-1)*(N_stages)+5),((inif(64)-1)*(N_stages)+5),...
   ((inif(65)-1)*(N_stages)+5),((inif(66)-1)*(N_stages)+5),((inif(67)-1)*(N_stages)+5),((inif(68)-1)*(N_stages)+5),((inif(69)-1)*(N_stages)+5),((inif(70)-1)*(N_stages)+5),((inif(71)-1)*(N_stages)+5),...
   ((inif(72)-1)*(N_stages)+5),((inif(73)-1)*(N_stages)+5),((inif(74)-1)*(N_stages)+5),((inif(75)-1)*(N_stages)+5),((inif(76)-1)*(N_stages)+5),((inif(77)-1)*(N_stages)+5),((inif(78)-1)*(N_stages)+5),((inif(79)-1)*(N_stages)+5),...
   ((inif(80)-1)*(N_stages)+5),((inif(81)-1)*(N_stages)+5)];

% ind = [((inif(1)-1)*(N_stages)+5),((inif(2)-1)*(N_stages)+5),((inif(3)-1)*(N_stages)+5),((inif(4)-1)*(N_stages)+5),((inif(5)-1)*(N_stages)+5),((inif(6)-1)*(N_stages)+5),((inif(7)-1)*(N_stages)+5),...
%    ((inif(8)-1)*(N_stages)+5),((inif(9)-1)*(N_stages)+5),((inif(10)-1)*(N_stages)+5),((inif(11)-1)*(N_stages)+5),((inif(12)-1)*(N_stages)+5),((inif(13)-1)*(N_stages)+5),((inif(14)-1)*(N_stages)+5),...
%    ((inif(15)-1)*(N_stages)+5),((inif(16)-1)*(N_stages)+5),((inif(17)-1)*(N_stages)+5),((inif(18)-1)*(N_stages)+5),((inif(19)-1)*(N_stages)+5),((inif(20)-1)*(N_stages)+5),((inif(21)-1)*(N_stages)+5),...
%    ((inif(22)-1)*(N_stages)+5),((inif(23)-1)*(N_stages)+5),((inif(24)-1)*(N_stages)+5),((inif(25)-1)*(N_stages)+5)];


x(ind) = 20; % adult mated females

x_hist=x; %We start the array x_hist to keep a historic of the evolution of the states

for t=1:(Simulation_time-1) %Loop for the simulation
    
    x = A_dis*x; %Compute the state at the next time step
    x_hist = [x_hist,x]; %Store the states
    
    %We recompute A based on the new temperature (for each area)
   
    for i = 1:N_stages
    for j = 1:N_trees
    
        G_R(i,j) = growth_rate(Temp_areas(j,t+1), a, T_l, T_m, m); 
        if t <= 80
        B_R(i,j) = 0
        else
        B_R(i,j) = birth_rate_suzuki(Temp_areas(j,t+1), alpha, gamma, lambda, delta, tau);  
        end
        S_R(i,j) = s_r;
        R_remate(i,j) = r_remate;
        R_mate(i,j) = r_mate;

if Temp_areas(j,t+1) >= 11 && Temp_areas(j,t+1) <= 27
%if t >= 120 && t <= 150
        if i == 1
            M_R(i,j) = mortality_rate_eggs(Temp_areas(j,t+1), k1,t1,r1)*G_R(i,j);
        elseif ismember(i, [2, 3, 4])
            M_R(i,j) = mortality_rate_larvae(Temp_areas(j,t+1), k2,t2,r2)*G_R(i,j);
        elseif i == 5
            M_R(i,j) = mortality_rate_pupae(Temp_areas(j,t+1), k3,t3,r3)*G_R(i,j);
        elseif i >= 6 && i <= 11
            M_R(i,j) = mortality_rate_adults(Temp_areas(j,t+1), k4,t4,r4)*G_R(i,j);
        end
elseif Temp_areas(j,t+1) < 11 || Temp_areas(j,t+1) > 27
%if t < 120 && t > 150
         if i == 1
            M_R(i,j) = mortality_rate_eggs(Temp_areas(j,t+1), k1,t1,r1)*(1/10);
        elseif ismember(i, [2, 3, 4])
            M_R(i,j) = mortality_rate_larvae(Temp_areas(j,t+1), k2,t2,r2)*(1/10);
        elseif i == 5
            M_R(i,j) = mortality_rate_pupae(Temp_areas(j,t+1), k3,t3,r3)*(1/120);
        elseif i >= 6 && i <= 11
            M_R(i,j) = mortality_rate_adults(Temp_areas(j,t+1), k4,t4,r4)*(1/30);
        end
    end
end
    end

    
    Pest_stages = Initialize_stages_ode(B_R,M_R,G_R,S_R,R_mate,R_remate,Pest_stages,N_trees,N_stages); %We initialize the parameters associated to each stage class

    %Update the matrix A
    A_cont = compute_A_wind_trap_rep(N_trees,Pest_stages,N_stages,Adj,u(:,t+1),v(:,t+1),z(:,t+1),Adj_w ,w(t+1,:),trap_efficiency,mort_trap,rep_efficiency);
    sysc = ss(A_cont,[],eye((N_stages)*N_trees),[]);
    sysd = c2d(sysc,1,'zoh');
    A_dis = sysd.A;
    
end

elapsed_time_seconds = toc;
elapsed_time_minutes = elapsed_time_seconds / 60;
disp(['Minutes: ', num2str(elapsed_time_minutes, '%.2f'), ' minutes.']);

%% Stages_indices

% 1
egg_stage = 1;
egg_stage_indices = egg_stage:N_stages:(N_stages*N_trees);

% 2,3,4
larval_stages = 2:4;  
larval_stage_indices = [];

for stage = larval_stages
    larval_stage_indices = [larval_stage_indices, stage:N_stages:(N_stages*N_trees)];
end

% 5
pupal_stage = 5;
pupal_stage_indices = pupal_stage:N_stages:(N_stages*N_trees);

% 6
Am_stage = 6;
Am_stage_indices = Am_stage:N_stages:(N_stages*N_trees);

% 7
Af_nm_stage = 7;
Af_nm_stage_indices = Af_nm_stage:N_stages:(N_stages*N_trees);

% 8
Af_m_stage = 8;
Af_m_stage_indices = Af_m_stage:N_stages:(N_stages*N_trees);

% 6,7,8
Adult_stages = 6:8;
Adult_stages_indices = [];

for stage = Adult_stages
    Adult_stages_indices = [Adult_stages_indices, stage:N_stages:(N_stages*N_trees)];
end

% 9,10,11
Trapped_stages = 9:11;
Trapped_stages_indices = [];

for stage = Trapped_stages
    Trapped_stages_indices = [Trapped_stages_indices, stage:N_stages:(N_stages*N_trees)];
end

%% Global individuals sum
% Parameters
N_stages = 11;        % Stages
N_trees = 81;         % Trees

global_population_e = sum(x_hist(egg_stage_indices, :), 'all');

global_population_l = sum(x_hist(larval_stage_indices, :), 'all');

global_population_p = sum(x_hist(pupal_stage_indices, :), 'all');

global_population_a = sum(x_hist(Adult_stages_indices, :), 'all');

global_population_tr = sum(x_hist(Trapped_stages_indices, :), 'all');


%% Adults sum in trap_areas
trap_stage_indices = [];
for i = 1:length(trap_areas)
    trap_stage_indices = [trap_stage_indices, Adult_stages + (trap_areas(i) - 1) * N_stages];
end

% Sum the population in trap nodes for the target stage
Adults_population_traps = sum(x_hist(trap_stage_indices, :), 'all');

%% Adults sum in rep_areas
rep_stage_indices = [];
for i = 1:length(rep_areas)
    rep_stage_indices = [rep_stage_indices, Adult_stages + (rep_areas(i) - 1) * N_stages];
end

% Sum the population in trap nodes for the target stage
Adults_population_reps = sum(x_hist(rep_stage_indices, :), 'all');

%% Adults sum in notrap/norep areas

all_areas = 1:N_trees;
trap_rep_areas = union(trap_areas, rep_areas);
notrap_norep_areas = setdiff(all_areas, trap_rep_areas);

notrap_norep_stage_indices = [];
for i = 1:length(notrap_norep_areas)
    node = notrap_norep_areas(i);
    notrap_norep_stage_indices = [notrap_norep_stage_indices, Adult_stages + (node - 1) * N_stages];
end
Adults_population_notrap_norep = sum(x_hist(notrap_norep_stage_indices, :), 'all');


writematrix(x_hist, 'x_hist.xlsx');

x_hist_control = readmatrix('x_hist_controllo.xlsx');

% x_hist_traps = readmatrix('x_hist_traps.xlsx');


%% PLOTS
t1 = datetime(2020,4,1,12,0,0); %Simulations starting the first of April
t=t1+days(0:Simulation_time-1);


% Global_plots vs control

% 1 - Egg Population
figure
plot(t, sum(x_hist(egg_stage_indices, :)), 'b', 'LineWidth', 1, 'DisplayName', 'Strategy'); % Blu
hold on
plot(t, sum(x_hist_control(egg_stage_indices, :)), 'r--', 'LineWidth', 1, 'DisplayName', 'Control'); % Rosso tratteggiato
hold off
xlabel('Time (days)');
ylabel('Number of insects');
title('Total Egg Population');
legend('show');

% 2,3,4 - Larval Population
figure
plot(t, sum(x_hist(larval_stage_indices, :)), 'b', 'LineWidth', 1, 'DisplayName', 'Strategy');
hold on
plot(t, sum(x_hist_control(larval_stage_indices, :)), 'r--', 'LineWidth', 1, 'DisplayName', 'Control');
hold off
xlabel('Time (days)');
ylabel('Number of insects');
title('Total Larval Population');
legend('show');

% 5 - Pupal Population
figure
plot(t, sum(x_hist(pupal_stage_indices, :)), 'b', 'LineWidth', 1, 'DisplayName', 'Strategy');
hold on
plot(t, sum(x_hist_control(pupal_stage_indices, :)), 'r--', 'LineWidth', 1, 'DisplayName', 'Control');
hold off
xlabel('Time (days)');
ylabel('Number of insects');
title('Total Pupal Population');
legend('show');

% 6,7,8 - Adult Population
figure
plot(t, sum(x_hist(Adult_stages_indices, :)), 'b', 'LineWidth', 1, 'DisplayName', 'Strategy');
hold on
plot(t, sum(x_hist_control(Adult_stages_indices, :)), 'r--', 'LineWidth', 1, 'DisplayName', 'Control');
hold off
xlabel('Time (days)');
ylabel('Number of insects');
title('Total Adult Population');
legend('show');

% 9,10,11 - Trapped Adult Population
figure
plot(t, sum(x_hist(Trapped_stages_indices, :)), 'b', 'LineWidth', 1, 'DisplayName', 'Strategy');
hold on
plot(t, sum(x_hist_control(Trapped_stages_indices, :)), 'r--', 'LineWidth', 1, 'DisplayName', 'Control');
hold off
xlabel('Time (days)');
ylabel('Number of insects');
title('Total Trapped Population');
legend('show');



% Adults in trap_areas

figure
hold on

for i = 1:length(trap_areas)
    node = trap_areas(i);  
    indices = Adult_stages + (N_stages * (node - 1));  
    total_adults = sum(x_hist(indices, :), 1);  

    plot(t, total_adults, 'LineWidth', 1, 'DisplayName', sprintf('Node %d', node));
end

hold off

legend('show');  
xlabel('Time (days)');
ylabel('Number of insects');
title('Adult Population in Trap Areas');



% Adults in rep_areas

figure
hold on

for i = 1:length(rep_areas)
    node = rep_areas(i);  
    indices = Adult_stages + (N_stages * (node - 1));  
    total_adults = sum(x_hist(indices, :), 1);  

    plot(t, total_adults, 'LineWidth', 1, 'DisplayName', sprintf('Node %d', node));
end

hold off

legend('show');  
xlabel('Time (days)');
ylabel('Number of insects');
title('Adult Population in Rep Areas');


% Adults in notrap_norep_areas

figure
hold on
for i = 1:length(notrap_norep_areas)
    node = notrap_norep_areas(i);
    indices = Adult_stages + (node - 1) * N_stages;  
    total_adults = sum(x_hist(indices, :), 1);  
    plot(t, total_adults, 'LineWidth', 1, 'DisplayName', sprintf('Node %d', node));
end
hold off

legend('show');  
xlabel('Time (days)');
ylabel('Number of insects');
title('Adult Population in Areas without Treatments');





% Global_plots vs control vs traps

% % 1 - Egg Population
% figure
% plot(t, sum(x_hist(egg_stage_indices, :)), 'b', 'LineWidth', 1, 'DisplayName', 'Strategy'); 
% hold on
% plot(t, sum(x_hist_control(egg_stage_indices, :)), 'r--', 'LineWidth', 1, 'DisplayName', 'Control'); 
% plot(t, sum(x_hist_traps(egg_stage_indices, :)), 'g--', 'LineWidth', 1, 'DisplayName', 'Traps'); 
% hold off
% xlabel('Time (days)');
% ylabel('Number of insects');
% title('Total Egg Population');
% legend('show');
% 
% % 2,3,4 - Larval Population
% figure
% plot(t, sum(x_hist(larval_stage_indices, :)), 'b', 'LineWidth', 1, 'DisplayName', 'Strategy');
% hold on
% plot(t, sum(x_hist_control(larval_stage_indices, :)), 'r--', 'LineWidth', 1, 'DisplayName', 'Control');
% plot(t, sum(x_hist_traps(larval_stage_indices, :)), 'g--', 'LineWidth', 1, 'DisplayName', 'Traps');
% hold off
% xlabel('Time (days)');
% ylabel('Number of insects');
% title('Total Larval Population');
% legend('show');
% 
% % 5 - Pupal Population
% figure
% plot(t, sum(x_hist(pupal_stage_indices, :)), 'b', 'LineWidth', 1, 'DisplayName', 'Strategy');
% hold on
% plot(t, sum(x_hist_control(pupal_stage_indices, :)), 'r--', 'LineWidth', 1, 'DisplayName', 'Control');
% plot(t, sum(x_hist_traps(pupal_stage_indices, :)), 'g--', 'LineWidth', 1, 'DisplayName', 'Traps');
% hold off
% xlabel('Time (days)');
% ylabel('Number of insects');
% title('Total Pupal Population');
% legend('show');
% 
% % 6,7,8 - Adult Population
% figure
% plot(t, sum(x_hist(Adult_stages_indices, :)), 'b', 'LineWidth', 1, 'DisplayName', 'Strategy');
% hold on
% plot(t, sum(x_hist_control(Adult_stages_indices, :)), 'r--', 'LineWidth', 1, 'DisplayName', 'Control');
% plot(t, sum(x_hist_traps(Adult_stages_indices, :)), 'g--', 'LineWidth', 1, 'DisplayName', 'Traps');
% hold off
% xlabel('Time (days)');
% ylabel('Number of insects');
% title('Total Adult Population');
% legend('show');
% 
% % 9,10,11 - Trapped Adult Population
% figure
% plot(t, sum(x_hist(Trapped_stages_indices, :)), 'b', 'LineWidth', 1, 'DisplayName', 'Strategy');
% hold on
% plot(t, sum(x_hist_control(Trapped_stages_indices, :)), 'r--', 'LineWidth', 1, 'DisplayName', 'Control');
% plot(t, sum(x_hist_traps(Trapped_stages_indices, :)), 'g--', 'LineWidth', 1, 'DisplayName', 'Traps');
% hold off
% xlabel('Time (days)');
% ylabel('Number of insects');
% title('Total Trapped Population');
% legend('show');







% Global_plots

% % 1
% figure
% plot(t,sum(x_hist(egg_stage_indices, :)),'LineWidth',1);
% xlabel('time (days)');
% ylabel('Number insects');
% title('Total Egg Population');
% 
% 
% % 2,3,4
% figure
% plot(t,sum(x_hist(larval_stage_indices, :)),'LineWidth',1);
% xlabel('time (days)');
% ylabel('Number insects');
% title('Total Larval Population');
% 
% % 5
% figure
% plot(t,sum(x_hist(pupal_stage_indices, :)),'LineWidth',1);
% xlabel('time (days)');
% ylabel('Number insects');
% title('Total Pupal Population');
% 
% % 6,7,8
% figure
% plot(t,sum(x_hist(Adult_stages_indices, :)),'LineWidth',1);
% xlabel('time (days)');
% ylabel('Number insects');
% title('Total Adult Population');
% 
% % 9,10,11
% figure
% plot(t,sum(x_hist(Trapped_stages_indices, :)),'LineWidth',1);
% xlabel('time (days)');
% ylabel('Number insects');
% title('Total Trapped Population');








% Adult male population in trap_areas
%  figure
%  plot(t,x_hist(6+(N_stages*0),:), 'LineWidth',1);
% t,x_hist(6+(N_stages*19),:),t,x_hist(6+(N_stages*20),:),t,x_hist(6+(N_stages*21),:),t,x_hist(6+(N_stages*22),:),...
%     t,x_hist(6+(N_stages*23),:),t,x_hist(6+(N_stages*24),:),t,x_hist(6+(N_stages*25),:),t,x_hist(6+(N_stages*26),:),t,x_hist(6+(N_stages*54),:),...
%     t,x_hist(6+(N_stages*55),:),t,x_hist(6+(N_stages*56),:),t,x_hist(6+(N_stages*57),:),t,x_hist(6+(N_stages*58),:),t,x_hist(6+(N_stages*59),:),...
%     t,x_hist(6+(N_stages*60),:),t,x_hist(6+(N_stages*61),:),t,x_hist(6+(N_stages*62),:), 'LineWidth',1);
% legend("Area 1","Area 2","Area 3","Area 4","Area 5","Area 6","Area 7","Area 8","Area 9","Area 10","Area 11","Area 12","Area 13","Area 14","Area 15","Area 16","Area 17","Area 18","Area 19","Area 20","Area 21","Area 22","Area 23","Area 24","Area 25");
% xlabel('time (days)');
% ylabel('Number insects');

%t,x_hist(6+(N_stages*18),:),t,x_hist(6+(N_stages*19),:),...
    %t,x_hist(6+(N_stages*20),:),t,x_hist(6+(N_stages*21),:),t,x_hist(6+(N_stages*22),:),t,x_hist(6+(N_stages*23),:),t,x_hist(6+(N_stages*24),:),
   
% Adult male population in rep_areas
% figure
% plot(t,x_hist(6+(N_stages*0),:),t,x_hist(6+(N_stages*1),:),t,x_hist(6+(N_stages*2),:),t,x_hist(6+(N_stages*3),:),t,x_hist(6+(N_stages*4),:),...
%     t,x_hist(6+(N_stages*5),:),t,x_hist(6+(N_stages*6),:),t,x_hist(6+(N_stages*7),:),t,x_hist(6+(N_stages*8),:),t,x_hist(6+(N_stages*36),:),...
%     t,x_hist(6+(N_stages*37),:),t,x_hist(6+(N_stages*38),:),t,x_hist(6+(N_stages*39),:),t,x_hist(6+(N_stages*40),:),t,x_hist(6+(N_stages*41),:),...
%     t,x_hist(6+(N_stages*42),:),t,x_hist(6+(N_stages*43),:),t,x_hist(6+(N_stages*44),:),t,x_hist(6+(N_stages*72),:),t,x_hist(6+(N_stages*73),:),...
%     t,x_hist(6+(N_stages*74),:),t,x_hist(6+(N_stages*75),:),t,x_hist(6+(N_stages*76),:),t,x_hist(6+(N_stages*77),:),t,x_hist(6+(N_stages*78),:),t,x_hist(6+(N_stages*79),:),t,x_hist(6+(N_stages*80),:),'LineWidth',1);
% legend("Area 1","Area 2","Area 3","Area 4","Area 5","Area 6","Area 7","Area 8","Area 9","Area 10","Area 11","Area 12","Area 13","Area 14","Area 15","Area 16","Area 17","Area 18","Area 19","Area 20","Area 21","Area 22","Area 23","Area 24","Area 25");
% xlabel('time (days)');
% ylabel('Number insects');

% % Adult male population in notrap/norep_areas
% figure
% plot(t,x_hist(6+(N_stages*9),:),t,x_hist(6+(N_stages*10),:),t,x_hist(6+(N_stages*11),:),t,x_hist(6+(N_stages*12),:),t,x_hist(6+(N_stages*13),:),t,x_hist(6+(N_stages*14),:),...
% t,x_hist(6+(N_stages*15),:),t,x_hist(6+(N_stages*16),:),t,x_hist(6+(N_stages*17),:),t,x_hist(6+(N_stages*27),:),t,x_hist(6+(N_stages*28),:),t,x_hist(6+(N_stages*29),:), ...
% t,x_hist(6+(N_stages*30),:),t,x_hist(6+(N_stages*31),:),t,x_hist(6+(N_stages*32),:),t,x_hist(6+(N_stages*33),:),t,x_hist(6+(N_stages*34),:),t,x_hist(6+(N_stages*35),:),...
% t,x_hist(6+(N_stages*45),:),t,x_hist(6+(N_stages*46),:),t,x_hist(6+(N_stages*47),:),t,x_hist(6+(N_stages*48),:),t,x_hist(6+(N_stages*49),:),t,x_hist(6+(N_stages*50),:),...
% t,x_hist(6+(N_stages*51),:),t,x_hist(6+(N_stages*52),:),t,x_hist(6+(N_stages*53),:),t,x_hist(6+(N_stages*63),:),t,x_hist(6+(N_stages*64),:),t,x_hist(6+(N_stages*65),:),...
% t,x_hist(6+(N_stages*66),:),t,x_hist(6+(N_stages*67),:),t,x_hist(6+(N_stages*68),:),t,x_hist(6+(N_stages*69),:),t,x_hist(6+(N_stages*70),:),t,x_hist(6+(N_stages*71),:),...
% 'LineWidth',1);
% legend("Area 11","Area 14","Area 17","Area 38","Area 41","Area 44","Area 65","Area 68","Area 71");
% xlabel('time (days)');
% ylabel('Number insects');


% Trapped adult males
% figure
% plot(t,x_hist(9+(N_stages*18),:),t,x_hist(9+(N_stages*19),:),t,x_hist(9+(N_stages*20),:),t,x_hist(9+(N_stages*21),:),t,x_hist(9+(N_stages*22),:),...
%     t,x_hist(9+(N_stages*23),:),t,x_hist(9+(N_stages*24),:),t,x_hist(9+(N_stages*25),:),t,x_hist(9+(N_stages*26),:),t,x_hist(9+(N_stages*54),:),...
%     t,x_hist(9+(N_stages*55),:),t,x_hist(9+(N_stages*56),:),t,x_hist(9+(N_stages*57),:),t,x_hist(9+(N_stages*58),:),t,x_hist(9+(N_stages*59),:),...
%     t,x_hist(9+(N_stages*60),:),t,x_hist(9+(N_stages*61),:),t,x_hist(9+(N_stages*62),:), 'LineWidth',1);
% legend("Area 1","Area 2","Area 3","Area 4","Area 5","Area 6","Area 7","Area 8","Area 9","Area 10","Area 11","Area 12","Area 13","Area 14","Area 15","Area 16","Area 17","Area 18","Area 19","Area 20","Area 21","Area 22","Area 23","Area 24","Area 25");
% xlabel('time (days)');
% ylabel('Number insects');

% ylim([0 3]);
% set(gca,'FontSize',18);
% 
