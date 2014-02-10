function [TrackedObjects] = CorrelateLocations(Dataset, i_Population, MinimumSeparation)

N_Frames = Dataset.N_Frames;

% Now correlate the locations of the found earlier Objects between frames
TrackedObjects = struct();
% Locate the initial ROI centers
N_Objects = Dataset.Frame(1).Population(i_Population).N_Objects;

% Construct a matrix of the object locations in that frame
Objects = Dataset.Frame(1).Population(i_Population).Object;%ObjectPositions{1};

InitialObjects = ObjectStructToXYMatrix(Objects);

% Calculate distances between Objects
Object_X_Matrix = zeros(N_Objects, N_Objects);
Object_Y_Matrix = zeros(N_Objects, N_Objects);
X = InitialObjects(1,:)';
Y = InitialObjects(2,:)';

for m = 1:N_Objects
    Object_X_Matrix(:,m) = X;
    Object_Y_Matrix(:,m) = Y;
end

Distance = sqrt((Object_X_Matrix - Object_X_Matrix').^2 + (Object_Y_Matrix - Object_Y_Matrix').^2);

% If the distance between objects is less than 5 pixels, discard them as
% unreliable, else use them as ROIs indicators

TooClose = sum(Distance < MinimumSeparation) - 1;


% Use the Objects that are not too close together to define the ROIs
i_ROI = 1;
for m = 1:N_Objects
    if ~TooClose(m)
        % Location and ROI size for analysis of next frame
        TrackedObjects(i_ROI).CurrentLocation = InitialObjects(:, m);
        %ROI(i_ROI).Size = 5; % Meant for later implementation
        % Position (+ size) over time
        TrackedObjects(i_ROI).Position = zeros(2, N_Frames);
        TrackedObjects(i_ROI).Position(:,1) = InitialObjects(:, m);
        % Error indicator
        TrackedObjects(i_ROI).oops = false;
        % Go to next ROI index
        i_ROI = i_ROI + 1;
    end
end

% Cycle over the frames and assign Objects to the ROI's
% Objects within n pixels of each other are discarded.
for m_Frame = 2:N_Frames
%     workbar(m_Frame/N_Frames,'Performing Object Correlation')
%     tic
    % Take object positions
    Objects = Dataset.Frame(m_Frame).Population(i_Population).Object;
    Positions = ObjectStructToXYMatrix(Objects);
    N_Objects = size(Positions, 2);
    % Calculate distance between objects
    Object_X_Matrix = zeros(N_Objects, N_Objects);
    Object_Y_Matrix = zeros(N_Objects, N_Objects);
    X = Positions(1,:)';
    Y = Positions(2,:)';
    for m_Objects = 1:N_Objects
        Object_X_Matrix(:,m_Objects) = X;
        Object_Y_Matrix(:,m_Objects) = Y;
    end
    Distance = sqrt((Object_X_Matrix - Object_X_Matrix').^2 + (Object_Y_Matrix - Object_Y_Matrix').^2);
    % Determine if Objects are too close together ( < MinimumDistance )
    TooClose = sum(Distance < MinimumSeparation) - 1; % -1 because the diagonal contains the distance between the Object and itself
    
    % Now determine if the objects fall within a ROI
    N_TrackedObjects = size(TrackedObjects, 2);
    TrackedObjects_Object_Distance = zeros(N_Objects, N_TrackedObjects);
    for m_ROI = 1:N_TrackedObjects
        for m_Object = 1:N_Objects
            TrackedObjects_Object_Distance(m_Object, m_ROI) = sqrt(...
                (X(m_Object) - TrackedObjects(m_ROI).CurrentLocation(1)).^2 + ...
                (Y(m_Object) - TrackedObjects(m_ROI).CurrentLocation(2)).^2);
        end
    end
    MultipleObjectsInROI = sum(TrackedObjects_Object_Distance < 3) > 1;
    [MinimumDistance, I_ObjectMinimum] = min(TrackedObjects_Object_Distance);
    
    % Accept if the particle diffused a maximum of 5 pixels and there is
    % only one object in the ROI
    for m_ROI = 1:N_TrackedObjects
        if MinimumDistance(m_ROI) < 5 && ~MultipleObjectsInROI(m_ROI) && ~TooClose(I_ObjectMinimum(m_ROI))
            TrackedObjects(m_ROI).CurrentLocation = Positions(1:2, I_ObjectMinimum(m_ROI));
            TrackedObjects(m_ROI).Position(:, m_Frame) = Positions(:, I_ObjectMinimum(m_ROI));
        else
            TrackedObjects(m_ROI).Position(:, m_Frame) = Positions(:, I_ObjectMinimum(m_ROI));
            TrackedObjects(m_ROI).oops = true;
        end
    end
%     toc
end


end

function Matrix = ObjectStructToXYMatrix(Objects)
% Determine the number of objects
N_Objects = numel(Objects);
% Preallocate the matrix
Matrix = zeros(2, N_Objects);
% Loop over all the items and store the centroid in an array
for i_Object = 1:N_Objects
    Matrix(1:2, i_Object) = Objects(i_Object).Centroid;
    
end
end