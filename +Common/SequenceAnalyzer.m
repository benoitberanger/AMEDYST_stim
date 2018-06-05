function results = SequenceAnalyzer( sequence, side, duration, from, to, KL )

if from == 0 || to == 0
    rawdata = cell(1,4);
else
    rawdata = KL.Data(from:to,:);
end

down_idx = cell2mat(rawdata(:,3));
downdata = rawdata(find(down_idx),:); %#ok<*FNDSB>

side_idx = regexp(downdata(:,1),side(1));
side_idx = ~cellfun(@isempty,side_idx);
side_idx = find(side_idx);
sidedata = downdata(side_idx,:);

seq = sidedata(:,1);
seq = cell2mat(seq);
if isempty(seq)
    seq = '';
else
    seq = seq(:,2)';
end

results         = struct;
results.rawdata = sidedata;

results.N     = length(seq);          % number of clicks
results.speed = length(seq)/duration; % clicks per seconds

completSeq = regexp(seq,sequence);
results.completSeq = length(completSeq);

% inter_tap_interval
iti = diff(cell2mat(sidedata(:,2)));
iti = round(iti*1000);
results.iti      = iti;              % milliseconds
results.iti_mean = round(nanmean(iti)); % milliseconds
results.iti_std  = round(nanstd(iti));  % milliseconds

% error
results.error = results.N - results.completSeq*length(sequence);

end % function
