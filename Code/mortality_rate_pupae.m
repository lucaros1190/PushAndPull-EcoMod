function M = mortality_rate_pupae(T, k3,t3,r3)
    %Input = Temperature and pupae parameters
    %Output = Daily mortality rate

    % if T <= 9 || T >= 32 
    %     M = 0.85;
    % else
        M = k3 * exp(1 + ((t3 - T) / r3) - exp((t3 - T) / r3))
        M = 1 - M
        
    % end

    if M < 0
        M = 0;
    end 
end