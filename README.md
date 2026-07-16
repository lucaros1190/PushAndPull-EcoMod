
**Matlab script to reproduce the results of Animobono et al. 2026, Ecological Modelling (under review)
**

This MATLAB code implements a spatially explicit, stage-structured population model for _Bactrocera oleae_. The model describes the dynamics of an insect population distributed among multiple interconnected sub-areas and includes biological processes such as development, mortality and reproduction, together with wind-driven dispersal and control strategies.
The spatial structure is represented as a network of interconnected sub-areas. The population within each sub-area is represented by a vector of developmental stages describing the insect life cycle. The population dynamics of each sub-area is driven by a stage-specific transition matrix, while dispersal among sub-areas is regulated by the adjacency relationships of the spatial graph, wind direction and intensity, and the presence of control strategies.
The model has been developed to simulate different spatial configurations and management scenarios. Users can modify biological parameters, environmental conditions and management strategies according to their specific experimental or modelling aims.

**Code organisation:**

The code is composed of several MATLAB files. The main script used to initialize and run simulations is ‘Script_wind_trap_rep.m’, while the remaining files contain the functions required by the model.

- Script_wind_trap_rep.m: Main script. It initializes model parameters, environmental inputs, spatial configuration and management scenarios, runs the simulation, and saves and plots the results.
- Adjency_matrix.m: Generates the spatial graph by defining the adjacency relationships among sub-areas. It identifies connected sub-areas and provides information on their relative position.
- compute_A_wind_trap_rep.m: Builds the transition matrices of the model. It defines the conditions governing spatial movements among sub-areas based on the presence of management strategies, the relative position of connected sub-areas, and wind direction.
- Initialize_stages_ode.m: Assigns temperature-dependent rates (development, mortality and fertility) and other stage-specific parameters to each population state.
- stage.m: Defines the MATLAB class used to store the parameters associated with each developmental stage.
- growth_rate.m: Defines the MATLAB class used to store the parameters associated with each developmental stage.
- birth_rate.m: Calculates temperature-dependent fertility rates.
- mortality_rate_eggs.m: Calculates temperature-dependent mortality rates for eggs.
- mortality_rate_larvae.m: Calculates temperature-dependent mortality rates for larval stages.
- mortality_rate_pupae.m: Calculates temperature-dependent mortality rates for pupae.
- mortality_rate_adults.m: Calculates temperature-dependent mortality rates for adults.
- data_pantheon_2020.mat: MATLAB data file containing the daily meteorological variables used by the model.

_Meteorological input data_

Meteorological variables are provided through a MATLAB data file (.mat). The file must contain three vectors of daily values:
- temperature: daily mean temperature (°C);
- wind_direction: daily mean wind direction (degrees); 
- wind_speed: daily mean wind speed (m s⁻¹).

The three vectors must have the same length, corresponding to the number of simulated days.
The default dataset included in the repository (data_pantheon_2020.mat) contains the meteorological observations used for the simulations presented in the study.
To simulate different environmental conditions, users can simply replace this file with another MATLAB data file having the same variable names and structure.

_Running a simulation_

‘Script_wind_trap_rep.m’ is the main script required to run a simulation. Most of the parameters defining the simulation scenario can be modified directly within this file.
The following sections highlight the parameters that can be customised.

Migration and control parameters:

- rep_efficiency: intensity of the repellent effect.
- trap_efficiency: attractiveness of traps.
- mort_trap: additional mortality rate associated with trap-treated sub-areas.
- k_factor: proportion of individuals transported by the wind.
- saturation: maximum wind speed (m s⁻¹) above which insect movement is inhibited.

Rate function parameters:

The model structure is designed to be flexible and can be adapted to different insect species. If the rate functions provided in the corresponding files are suitable for the target species, only the species-specific parameters defining the development, mortality and fertility functions, together with the sex ratio of newly emerged adults (s_r) and the mating parameters (r_mate and r_remate), need to be modified.
Additional parameters:
- N_stages: total number of population states included in the model, including the additional trapped states. 
- N_trees: total number of sub-areas composing the graph representing the simulated field. 
The following section of the script loads the .mat file containing the environmental data:
load('data_pantheon_2020');

The management scenario is then defined through the following variables:
- trap_areas = [];   % Sub-areas where traps are deployed
- rep_areas  = [];   % Sub-areas where repellents are applied
- trap_time  = [];   % Time interval during which traps are active
- rep_time   = [];   % Time interval during which repellents are active
The vectors trap_areas and rep_areas define the sub-areas where traps and repellents are deployed, respectively. The vectors trap_time and rep_time specify the periods during which each management strategy is active. By modifying these variables, users can simulate different spatial arrangements and management schedules. Several example configurations are included in the main script as commented code and can be activated or modified according to the simulation objectives.
Within the graph representing the study field, sub-areas are numbered from left to right and from bottom to top. A graphical representation of this numbering scheme is provided in Figure 2 of the manuscript.

The spatial configuration of the graph is defined by the following function call:
% Spatial configuration
[Adj, Adj_w, Link] = Adjency_matrix(9,9);
The arguments of Adjency_matrix specify the number of columns and rows of the adjacency matrix, thereby defining the size of the graph representing the study field.
The following section allows users to define the initial conditions of the simulation.
% Areas initially infested
inif = [1];

% Initial conditions
ind = [((inif(1)-1)*(N_stages)+5)];

x(ind) = 20;
The vector ‘inif’ specifies the initially infested sub-areas, whereas the vector ‘ind’ associates each selected sub-area with the developmental stage used as the initial condition. The stage is identified by the integer added at the end of the expression defining ind. In the example above, the value 5 corresponds to the pupal stage of B. oleae, which is the fifth developmental stage. The variable x(ind) specifies the number of individuals assigned to each selected sub-area at the beginning of the simulation.

Model outputs:

During the simulation, the temporal evolution of all population states is stored in the matrix ‘x_hist’.
This matrix contains the population density of each developmental stage in every sub-area over time. The same matrix is also used as the input for the plotting section of the script, where users can visualize the seasonal dynamics of selected developmental stages and/or selected groups of sub-areas. Several examples are provided to illustrate how to plot different developmental stages or different classes of sub-areas (trap-treated, repellent-treated or untreated areas).
The script also includes several examples of calculations and visualisations that can be adapted according to the user's specific needs.

_Notes on the remaining files_

- Adjency_matrix.m: the number of rows and columns defining the adjacency matrix, and therefore the size of the graph representing the study field, is specified in ‘Script_wind_trap_rep.m’, as described above. 
- compute_A_wind_trap_rep.m: this function requires as input the number of sub-areas, the number of developmental stages, the adjacency matrices generated by Adjency_matrix.m, and the parameters governing migration rates, which are defined in ‘Script_wind_trap_rep.m’. 
- Initialize_stages_ode.m: this function assigns the stage-specific rates to the model. It requires as input the development, mortality and fertility rates, together with the number of sub-areas and developmental stages, all of which are defined in ‘Script_wind_trap_rep.m’. 
- stage.m: defines the MATLAB class used to store the demographic parameters associated with each developmental stage. No modifications are normally required in this file.
- growth_rate.m, birth_rate_suzuki.m, mortality_rate_*.m
These files contain the temperature-dependent demographic rate functions. If alternative formulations are required for a different insect species, these functions can be modified or replaced. Any associated parameters should also be updated in the corresponding section of ‘Script_wind_trap_rep.m’.

_Recommended workflow_

A typical simulation workflow is:

1. Prepare a meteorological .mat file containing daily temperature, wind direction and wind speed. 
2. Open ‘Script_wind_trap_rep.m.’ 
3. Define the biological parameters and management scenario. 
4. Modify the spatial configuration according to the study area. 
5. Select, in the plotting section, the developmental stages and spatial areas whose population dynamics will be visualized. 
6. Run the simulation.
