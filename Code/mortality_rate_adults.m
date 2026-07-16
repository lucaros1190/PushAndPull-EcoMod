function M = mortality_rate_adults(T, k4,t4,r4)
    %Input = Temperature and adults parameters
    %Output = Daily mortality rate

    % if T <= 9 || T >= 32
    %     M = 0.85;
    % else
        M = k4 * exp(1 + ((t4 - T) / r4) - exp((t4 - T) / r4))
        M = 1 - M
        
    % end

    if M < 0
        M = 0;
    end 
end