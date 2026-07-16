function M = mortality_rate_larvae(T, k2,t2,r2)
    %Input = Temperature and larvae parameters
    %Output = Daily mortality rate

   
    % if T <= 6 || T >= 32 
    %     M = 0.9;
    % else
        M = k2 * exp(1 + ((t2 - T) / r2) - exp((t2 - T) / r2))
        M = 1 - M
        
    % end

    if M < 0
        M = 0;
    end 
end