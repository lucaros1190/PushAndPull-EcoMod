function M = mortality_rate_eggs(T, k1,t1,r1)
    %Input = Temperature and eggs parameters
    %Output = Daily mortality rate

    % if T <= 6 || T >= 32 
    %     M = 0.9;
    % else
        M = k1 * exp(1 + ((t1 - T) / r1) - exp((t1 - T) / r1))
        M = 1 - M
       
    % end

    if M < 0
        M = 0;
    end 
end