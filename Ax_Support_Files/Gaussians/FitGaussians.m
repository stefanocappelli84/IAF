%% Function FitGaussians
% This functions allows the user to fit a bead profile (I(r)) in
% Dataset.BeadTemplate.BeadProfile with one or more Gaussian profiles. The
% number of Gaussians and the initial parameters are selected in a simple
% GUI by the user.
function Dataset = FitGaussians(Dataset)

% profile to fit

BeadProfile = Dataset.BeadTemplate.BeadProfile;
% Offset the last datapoint to zero
BeadProfile = BeadProfile - BeadProfile(numel(BeadProfile));

X = 1:numel(BeadProfile);


% Profile = GaussProfile(1:35, Ampl, Centr, Sigma);

% Get the peaks from user input
figure;
plot(BeadProfile, 'ro');
title('Click on the maxima of the gauss peaks and finally press Return (ENTER)');
[SelectedX, SelectedY] = ginput();
close;

% Estimate initial fitting parameters
N_Gauss = numel(SelectedX);

for i_Gauss = 1:N_Gauss
    
    Centr(i_Gauss) = SelectedX(i_Gauss);
    Ampl(i_Gauss) = SelectedY(i_Gauss);
    Sigma(i_Gauss) = 10;
    
end

Centr(1) = 0;% Fix first gauss at 0;

% Fit

% Beta = nlinfit(X, BeadProfile, @SingleGauss, [Ampl, Centr, Sigma]);

% Fitting:
% For every Gauss in the profile do this:
% 1: Remove the other (estimated) Gauss profiles from BeadProfile (this isolates the single gauss)
% 2: Fit this profile

Indices = 1:N_Gauss;

% Do ten iterations:

for iteration = 1:10
    
    for i_Gauss = 1:N_Gauss
        
        IsoInd = Indices(Indices ~= i_Gauss);
        
        IsolatedGauss = BeadProfile - GaussProfile1D(X, Ampl(IsoInd), Centr(IsoInd), Sigma(IsoInd));
        % Perform the fit
        if (i_Gauss == 1)
            Beta = nlinfit(X, IsolatedGauss, @SingleZeroCenteredGauss, [Ampl(i_Gauss), Sigma(i_Gauss)]);
            
            % Save the fitting parameters
            Ampl(i_Gauss) = Beta(1);
            Centr(1) = 0; % Fix first gauss at 0;
            Sigma(i_Gauss) = Beta(2);
        else
            Beta = nlinfit(X, IsolatedGauss, @SingleGauss, [Ampl(i_Gauss), Centr(i_Gauss), Sigma(i_Gauss)]);
            
            % Save the fitting parameters
            Ampl(i_Gauss) = Beta(1);
            Centr(i_Gauss) = Beta(2);
            Sigma(i_Gauss) = Beta(3);
        end
        
    end
    
end

% Store the created fit in the beadtemplate:

Dataset.BeadTemplate.Gaussians.Ampl = Ampl;
Dataset.BeadTemplate.Gaussians.Centr = Centr;
Dataset.BeadTemplate.Gaussians.Sigma = Sigma;

Dataset.BeadTemplate.BeadFilter = MultipleGaussBeadImage(Dataset.BeadTemplate.sizeROI, [0, 0], Ampl, Centr, Sigma);

% Calc best fitted shape

FittedX = 0:0.01:X(end);
FittedProfile = GaussProfile1D(FittedX, Ampl, Centr, Sigma);

% Show info

figure;
hold on;
plot(BeadProfile, 'ro');
plot(FittedX, FittedProfile);
title('Check fit and press ENTER');

% if strcmp(questdlg('Fit ok?', 'More', 'Yes', 'No', 'Yes'), 'No')
%     
% end

waitfor(gcf, 'CurrentCharacter', 13)

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%        Supporting functions         %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Function for fitting of a Gauss
function [Gauss] = SingleGauss(Parameters, X)

Ampl = Parameters(1);
Centr = Parameters(2);
Sigma = Parameters(3);

Gauss = Ampl*exp(-(((X-Centr).^2)./(2.*Sigma)));

end

% Function for fitting of a zero centered Gauss
function [Gauss] = SingleZeroCenteredGauss(Parameters, X)

Ampl = Parameters(1);
Sigma = Parameters(2);

Gauss = Ampl*exp(-(((X).^2)./(2.*Sigma)));

end

% Function to make a sample plot of the fitting curve
function [Y] = GaussProfile1D(X, Ampl, Centr, Sigma)

% Initialization code:
Y = zeros(size(X));
N_Gauss = numel(Ampl);

% Incrementally add all the Gaussians
for i_Gauss = 1:N_Gauss
    Y = Y + Ampl(i_Gauss)*exp(-(((X-Centr(i_Gauss)).^2)./(2.*Sigma(i_Gauss))));    
end

end










