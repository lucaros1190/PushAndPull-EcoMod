function Pest_stages = Initialize_stages_ode(Birth,Death,Growth,S_R,R_mate,R_remate,Pest_stages,N_trees,N_stages)
    %Input =  Different rates at each instant
    %Output =  Parameters associated to each stage
    for i=1:N_stages
    for j=1:N_trees
       
            Pest_stages(i,j).birth = Birth(i,j);
            Pest_stages(i,j).death = Death(i,j);
            Pest_stages(i,j).growth = Growth(i,j);
            Pest_stages(i,j).sex_ratio = S_R(i,j);
            Pest_stages(i,j).mate = R_mate(i,j);
            Pest_stages(i,j).remate = R_remate(i,j);
          

        end
    end

end