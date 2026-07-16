function A_tot = compute_A_wind_trap_rep(N_trees,Pest_stages,stages, Adj,u,v,z,Adj_w,w,trap_efficiency,mort_trap,rep_efficiency)
    
    %Total number of states
    n = N_trees*stages;
    
    indices = find(u>0); % Nodes with a trap
    notrap_indices = find(z<1) % Nodes without traps or repellent
    rep_indices = find(v>0); % Nodes with a repellent

    %Check the directions of the wind
    sign_w = sign(w);
    
    %Compute the A matrix for each area
    for i = 1:N_trees
        
        A_sing{i} = [-Pest_stages(1,i).growth-Pest_stages(1,i).death 0 0 0 0 0 0  Pest_stages(8,i).birth 0 0 0;... %Egg (1)
            Pest_stages(1,i).growth -Pest_stages(2,i).growth-Pest_stages(2,i).death  0 0 0 0 0 0 0 0 0;... %L1 (2)
            0 Pest_stages(2,i).growth -Pest_stages(3,i).growth-Pest_stages(3,i).death  0 0 0 0 0 0 0 0;... %L2 (3)
            0 0 Pest_stages(3,i).growth -Pest_stages(4,i).growth-Pest_stages(4,i).death  0 0 0 0 0 0 0;... %L3 (4)
            0 0 0  Pest_stages(4,i).growth -Pest_stages(5,i).growth-Pest_stages(5,i).death 0 0 0 0 0 0;...%P (5)
            0 0 0 0  Pest_stages(5,i).sex_ratio*Pest_stages(6,i).growth -Pest_stages(6,i).growth-Pest_stages(6,i).death 0 0 0 0 0;...%AM (6)
            0 0 0 0  (1-Pest_stages(6,i).sex_ratio)*Pest_stages(7,i).growth 0 -(Pest_stages(7,i).mate-Pest_stages(7,i).death) 0 0 0 0;...%NMF (7)
            0 0 0 0 0 0 Pest_stages(7,i).mate-Pest_stages(7,i).death -Pest_stages(8,i).growth-Pest_stages(8,i).death 0 0 0;... %MF (8)
            0 0 0 0 0 0 0 0 0 0 0;... %Traps AM (9)
            0 0 0 0 0 0 0 0 0 0 0;... %Traps NMF (10)
            0 0 0 0 0 0 0 0 0 0 0]; %Traps MF (11) 
  
    end

    
    %% Outgoing movements section

    % Movement from notrap_nodes to trap_nodes
    % With wind blowing from trap_nodes to notrap_nodes
    for i = notrap_indices'
    temp_jump =0;
      for j = indices'
        if ~isempty(indices)
          if Adj_w(i,j)*sign_w(1) == -2 || Adj_w(i,j)*sign_w(2) == -1       % Wind direction between the two nodes
                   
             if  Adj_w(i,j)*sign_w(1) == -2

             temp_jump = temp_jump  - (abs(w(1)) + trap_efficiency);        % Trap efficiency enhanced by wind direction
             end
             if  Adj_w(i,j)*sign_w(2) == -1
             temp_jump = temp_jump  - (abs(w(2)) + trap_efficiency);
             end

           end
         end
       end
               
             % Subtraction of adult individuals
             A_sing{i}(6,6) = A_sing{i}(6,6) + temp_jump;
             A_sing{i}(7,7) = A_sing{i}(7,7) + temp_jump;
             A_sing{i}(8,8) = A_sing{i}(8,8) + temp_jump;

    end 

    % Movement from notrap_nodes to trap_nodes
    % When the wind doesn't blow from trap_nodes to notrap_nodes
    for i = notrap_indices'
      for j = indices'
        if ~isempty(indices)
          if Adj(i,j)>0
            if Adj_w(i,j)*sign_w(1) ~= -2
              if Adj_w(i,j)*sign_w(2) ~= -1

                    
              % Subtraction of adult individuals
              A_sing{i}(6,6) = A_sing{i}(6,6) - trap_efficiency;
              A_sing{i}(7,7) = A_sing{i}(7,7) - trap_efficiency;
              A_sing{i}(8,8) = A_sing{i}(8,8) - trap_efficiency;
              end
            end
          end
        end
      end
    end

   


    % Movement from rep_nodes to trap_nodes
    % With wind blowing from trap_nodes to rep_nodes
    for i = rep_indices'
      if ~isempty (rep_indices)
      temp_jump =0;
        for j = indices'
          if ~isempty(indices)
            if Adj_w(i,j)*sign_w(1) == -2 || Adj_w(i,j)*sign_w(2) == -1     % Wind direction between the two nodes
                   
               if Adj_w(i,j)*sign_w(1) == -2
               temp_jump = temp_jump  - (abs(w(1)) + trap_efficiency + rep_efficiency); % Combined effect of repellence and attractiveness (+ wind)
               end
               if  Adj_w(i,j)*sign_w(2) == -1
               temp_jump = temp_jump  - (abs(w(2)) + trap_efficiency + rep_efficiency);
               end
             end
           end
         end
       end
               
               % Subtraction of adult individuals
               A_sing{i}(6,6) = A_sing{i}(6,6) + temp_jump;
               A_sing{i}(7,7) = A_sing{i}(7,7) + temp_jump;
               A_sing{i}(8,8) = A_sing{i}(8,8) + temp_jump;

    end 

    % Movement from rep_nodes to trap_nodes
    % When the wind doesn't blow from trap_nodes to rep_nodes
    for i = rep_indices'
      if ~isempty(rep_indices)
        for j = indices'
          if ~isempty(indices)
            if Adj(i,j)>0
              if Adj_w(i,j)*sign_w(1) ~= -2
                if Adj_w(i,j)*sign_w(2) ~= -1

                    
                % Subtraction of adult individuals
                A_sing{i}(6,6) = A_sing{i}(6,6) - (trap_efficiency + rep_efficiency); % Combined effect of repellence and attractiveness
                A_sing{i}(7,7) = A_sing{i}(7,7) - (trap_efficiency + rep_efficiency);
                A_sing{i}(8,8) = A_sing{i}(8,8) - (trap_efficiency + rep_efficiency);
                end
              end
            end
          end
        end
      end
    end

     % Trap mortality in trap_nodes
    for i = indices'

       % Removal of dead individuals
       A_sing{i}(6,6) = A_sing{i}(6,6) - mort_trap;
       A_sing{i}(7,7) = A_sing{i}(7,7) - mort_trap;
       A_sing{i}(8,8) = A_sing{i}(8,8) - mort_trap; 
       
       % Recording of catched individuals
       A_sing{i}(9,6) =  mort_trap;
       A_sing{i}(10,7) =  mort_trap;
       A_sing{i}(11,8) =  mort_trap; 

       % A_sing{i}(1,1) = A_sing{i}(1,1) - mort_trap;
       % A_sing{i}(2,2) = A_sing{i}(2,2) - mort_trap;
       % A_sing{i}(3,3) = A_sing{i}(3,3) - mort_trap; 
       % A_sing{i}(4,4) = A_sing{i}(4,4) - mort_trap; 
       % A_sing{i}(5,5) = A_sing{i}(5,5) - mort_trap; 

    end 

    % Movement from notrap_nodes to notrap_nodes
    % Having no preferencial directions, insects are carried by the wind
    for i =notrap_indices'
      if isempty(intersect(indices,find(Adj(i,:)>0))) % Only if there are no trap_nodes around a notrap_node
      temp_jump =0;
        for j = notrap_indices'
                    
          if  Adj_w(i,j)*sign_w(1) == 2
          temp_jump = temp_jump  - abs(w(1));
          end
          if  Adj_w(i,j)*sign_w(2) == 1
          temp_jump = temp_jump  - abs(w(2));
          end
        end    
        % Subtraction of adult individuals
        A_sing{i}(6,6) = A_sing{i}(6,6) + temp_jump;
        A_sing{i}(7,7) = A_sing{i}(7,7) + temp_jump;
        A_sing{i}(8,8) = A_sing{i}(8,8) + temp_jump;
      end
    end



    % Movement from rep_nodes to notrap_nodes: (when a rep_node is
    % sorrounded by notrap_nodes, flies disperse in every direction; the
    % route favored by the wind is preferred)

    % With wind blowing from rep_nodes to notrap_nodes 
    for i = rep_indices'
      if ~isempty(rep_indices)
      temp_jump=0
        if isempty (intersect(indices, find(Adj(i,:)>0))) % Only if there are no trap_nodes around a rep_node
          for j = notrap_indices'
           
          
          if  Adj_w(i,j)*sign_w(1) == 2
          temp_jump = temp_jump  - (abs(w(1)) + rep_efficiency);
          end
          if  Adj_w(i,j)*sign_w(2) == 1
          temp_jump = temp_jump  - (abs(w(2)) + rep_efficiency);
          end
                    
          
          end
                    
          % Subtraction of adult individuals
          A_sing{i}(6,6) = A_sing{i}(6,6) + temp_jump;
          A_sing{i}(7,7) = A_sing{i}(7,7) + temp_jump;
          A_sing{i}(8,8) = A_sing{i}(8,8) + temp_jump;

        end
      end
    end

    % Movement from rep_nodes to notrap_nodes 
    % When the wind doesn't blow from rep_nodes to notrap_nodes
    for i = rep_indices'
      if ~isempty(rep_indices)
        if isempty (intersect(indices,find(Adj(i,:)>0))) % Only if there are no trap_nodes around a rep_node
          for j = notrap_indices'
            if Adj(i,j)>0   
              if Adj_w(i,j)*sign_w(1) ~= 2   
                if Adj_w(i,j)*sign_w(2) ~= 1               
                % Subtraction of adult individuals
                A_sing{i}(6,6) = A_sing{i}(6,6) - rep_efficiency;
                A_sing{i}(7,7) = A_sing{i}(7,7) - rep_efficiency;
                A_sing{i}(8,8) = A_sing{i}(8,8) - rep_efficiency;

                end
              end
            end
          end
        end
      end    
    end

    %Create a block diagonal matrix based on each areas A matrix
    A = blkdiag(A_sing{:});
    
    %% Adding the non diagonal elements
    
    %Dummy matrix
    
       A_jump = [0 0 0 0 0 0 0 0 0 0 0;...%Egg (1)
        0 0 0 0 0 0 0 0 0 0 0;... %L1 (2)
        0 0 0 0 0 0 0 0 0 0 0;... %L2 (3)
        0 0 0 0 0 0 0 0 0 0 0;... %L3 (4)
        0 0 0 0 0 0 0 0 0 0 0;... %P (5)
        0 0 0 0 0 1 0 0 0 0 0;... %AM (6)
        0 0 0 0 0 0 1 0 0 0 0;... %NMF (7)
        0 0 0 0 0 0 0 1 0 0 0;... %MF (8)
        0 0 0 0 0 0 0 0 0 0 0;... %Traps AM (9)
        0 0 0 0 0 0 0 0 0 0 0;... %Traps NMF (10)
        0 0 0 0 0 0 0 0 0 0 0]; %Traps MF (11) 
    
    A_jump_tot = zeros(n,n);
    
    %% Incoming movements section

    % Movement from notrap_nodes to trap_nodes
    % With wind blowing from trap_nodes to notrap_nodes
    for i = notrap_indices'
      for k = indices'
        if ~isempty(indices)
        temp_jump=0
          if Adj_w(i,k)*sign_w(1) == -2 || Adj_w(i,k)*sign_w(2) == -1 % Wind direction between the two nodes
                   
          if  Adj_w(i,k)*sign_w(1) == -2
          temp_jump = (abs(w(1)) + trap_efficiency); % Trap efficiency enhanced by wind direction
          end
          if  Adj_w(i,k)*sign_w(2) == -1
          temp_jump = (abs(w(2)) + trap_efficiency);
          end

          A_jump_temp = A_jump.*temp_jump;


          temp_Adj = zeros(N_trees,N_trees);
          temp_Adj(k,i) = 1 ; % We insert it at the jump interaction
          A_jump_ind = kron(temp_Adj,A_jump_temp); % We expand to the overall system

          % We add to the big matrix
          A_jump_tot = A_jump_tot + A_jump_ind;
          end
        end
      end
    end

    % Movement from notrap_nodes to trap_nodes
    % When the wind doesn't blow from trap_nodes to notrap_nodes
    for i = notrap_indices'
      for k = indices'
        if ~isempty(indices)
          if Adj(i,k)>0
            if Adj_w(i,k)*sign_w(1) ~= -2
              if Adj_w(i,k)*sign_w(2) ~= -1

              A_jump_temp = A_jump.*trap_efficiency;
              temp_Adj = zeros(N_trees,N_trees);
              temp_Adj(k,i) = 1 ; % We insert it at the jump interaction
              A_jump_ind = kron(temp_Adj,A_jump_temp); %We expand to the overall system
            
              %We add to the big matrix
              A_jump_tot = A_jump_tot + A_jump_ind;
              end
            end
          end
        end
      end
    end


     
    % Movement from notrap_nodes to notrap_nodes
    % Having no preferencial directions, insects are carried by the wind
    for i = notrap_indices' 
      for k = notrap_indices'
        if isempty(intersect(indices,find(Adj(i,:)>0))) % Only if there are no trap_nodes around the notrap_node
        temp_jump = 0;
            
        if  Adj_w(i,k)*sign_w(1) == 2
        temp_jump =  abs(w(1));
        end
        if  Adj_w(i,k)*sign_w(2) == 1
        temp_jump =  abs(w(2));
        end
            
        A_jump_temp = A_jump.*temp_jump;
            
            
        temp_Adj = zeros(N_trees,N_trees);
        temp_Adj(k,i) = 1 ; % We insert it at the jump interaction
        A_jump_ind = kron(temp_Adj,A_jump_temp); % We expand to the overall system
            
        % We add to the big matrix
        A_jump_tot = A_jump_tot + A_jump_ind;
        end 
      end
    end

    % Movement from rep_nodes to trap_nodes
    % With wind blowing from trap_nodes to rep_nodes
    for i = rep_indices'
      if ~isempty(rep_indices)
        for k = indices'
          if ~isempty(indices)
          temp_jump=0
            if Adj_w(i,k)*sign_w(1) == -2 || Adj_w(i,k)*sign_w(2) == -1 % Wind direction between the two nodes
                   
            if  Adj_w(i,k)*sign_w(1) == -2
            temp_jump = (abs(w(1)) + trap_efficiency + rep_efficiency); % Combined effect of repellence and attractiveness (wind)
            end
            if  Adj_w(i,k)*sign_w(2) == -1
            temp_jump = (abs(w(2)) + trap_efficiency + rep_efficiency);
            end

            A_jump_temp = A_jump.*temp_jump;


            temp_Adj = zeros(N_trees,N_trees);
            temp_Adj(k,i) = 1 ; % We insert it at the jump interaction
            A_jump_ind = kron(temp_Adj,A_jump_temp); % We expand to the overall system

            %We add to the big matrix
            A_jump_tot = A_jump_tot + A_jump_ind;
            end
          end
        end
      end
    end

    % Movement from rep_nodes to trap_nodes
    % When the wind doesn't blow from trap_nodes to rep_nodes
    for i = rep_indices'
      if ~isempty(rep_indices) 
        for k = indices'
          if ~isempty(indices)
            if Adj(i,k)>0
              if Adj_w(i,k)*sign_w(1) ~= -2
                if Adj_w(i,k)*sign_w(2) ~= -1

                A_jump_temp = A_jump.*(trap_efficiency + rep_efficiency); % Combined effect of repellence and attractiveness
                temp_Adj = zeros(N_trees,N_trees);
                temp_Adj(k,i) = 1 ; % We insert it at the jump interaction
                A_jump_ind = kron(temp_Adj,A_jump_temp); %We expand to the overall system
            
                %We add to the big matrix
                A_jump_tot = A_jump_tot + A_jump_ind;
                end
              end
            end
          end
        end
      end
    end

    % Movement from rep_nodes to notrap_nodes: (when a rep_node is
    % sorrounded by notrap_nodes, flies disperse in every direction; the
    % route favored by the wind is preferred)

    % With wind blowing from rep_nodes to notrap_nodes
    for i = rep_indices' 
      if ~isempty(rep_indices)
        for k = notrap_indices'
          if isempty(intersect(indices,find(Adj(i,:)>0))) % Only if there are no trap_nodes around a rep_node
          temp_jump = 0;

          if  Adj_w(i,k)*sign_w(1) == 2
          temp_jump =  (abs(w(1)) + rep_efficiency);             
          end
          if  Adj_w(i,k)*sign_w(2) == 1
          temp_jump =  (abs(w(2)) + rep_efficiency);             
          end
            
          A_jump_temp = A_jump.*temp_jump;      
            
            
          temp_Adj = zeros(N_trees,N_trees);
          temp_Adj(k,i) = 1 ; % We insert it at the jump interaction
          A_jump_ind = kron(temp_Adj,A_jump_temp); %We expand to the overall system
            
          %We add to the big matrix
          A_jump_tot = A_jump_tot + A_jump_ind;
            
          end
        end
      end
    end

    % Movement from rep_nodes to notrap_nodes 
    % When the wind doesn't blow from rep_nodes to notrap_nodes
    for i = rep_indices'
      if ~isempty(rep_indices)
        if isempty (intersect(indices,find(Adj(i,:)>0))) % Only if there are no trap_nodes around a rep_node
          for k = notrap_indices'
            if Adj(i,k)>0   %se i due nodi sono adiacenti
              if Adj_w(i,k)*sign_w(2) ~= 1   
                if Adj_w(i,k)*sign_w(1) ~= 2

                A_jump_temp = A_jump.*rep_efficiency;
                temp_Adj = zeros(N_trees,N_trees);
                temp_Adj(k,i) = 1 ; % We insert it at the jump interaction
                A_jump_ind = kron(temp_Adj,A_jump_temp); %We expand to the overall system
            
                %We add to the big matrix
                A_jump_tot = A_jump_tot + A_jump_ind;
                end
              end
            end
          end
        end
      end
    end




   

      
 %The final matrix is the sum of the block diagonal matrix and the interactions matrix 
    A_tot = A + A_jump_tot; 
  
    
end
