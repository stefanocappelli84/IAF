function [Y] = GaussProfileR(R, Ampl, Centr, Sigma)

% Initialization code:
Y = 0;
N_Gauss = numel(Ampl);

% Incrementally add all the Gaussians
for i_Gauss = 1:N_Gauss
    Y = Y + Ampl(i_Gauss)*exp(-(((R-Centr(i_Gauss)).^2)./(2.*Sigma(i_Gauss))));    
end

end