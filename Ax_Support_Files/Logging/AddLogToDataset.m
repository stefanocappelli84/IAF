function Dataset = AddLogToDataset(Dataset, Log)

% Simply append the log to the dataset

if ~isfield(Dataset.Log, 'Functionlog')
    Dataset.Log.Functionlog(1).Log = Log;
else
    Dataset.Log.Functionlog(end+1).Log = Log;
end

end