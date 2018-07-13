function feat_data = FMe(sig_data, rel_data)
%FMe measures features from peak and trough values as specified in
% PC's literature review.

fprintf('\n--- Measuring Features ');
%% Settings
% choose which peaks and onsets:
rel_data.tr = rel_data.tr_min;
rel_data.p = rel_data.p_max;
fs = rel_data.fs;

if isempty(rel_data.tr.t) || isempty(rel_data.p.t)
    [peaks.t, peaks.v, onsets.t, onsets.v] = deal([]);
else 
    % Want an onset followed by a peak.
    if rel_data.tr.t(1) > rel_data.p.t(1)
        rel_data.p.t = rel_data.p.t(2:end);
        rel_data.p.v = rel_data.p.v(2:end);
    end
    % Want the same number of peaks and onsets
    diff_in_length = length(rel_data.p.t) - length(rel_data.tr.t);
    if diff_in_length > 0
        rel_data.p.t = rel_data.p.t(1:(end-diff_in_length));
        rel_data.p.v = rel_data.p.v(1:(end-diff_in_length));
    elseif diff_in_length < 0
        rel_data.tr.t = rel_data.tr.t(1:(end-diff_in_length));
        rel_data.tr.v = rel_data.tr.v(1:(end-diff_in_length));
    end
    % find onsets and peaks
    onsets.t = rel_data.tr.t; onsets.t = onsets.t(:);
    onsets.v = rel_data.tr.v; onsets.v = onsets.v(:);
    peaks.t = rel_data.p.t; peaks.t = peaks.t(:);
    peaks.v = rel_data.p.v; peaks.v = peaks.v(:);
    
end

%% Measure Features
feat_data = calc_bw(peaks, onsets, fs, sig_data);
feat_data.timings = rel_data.timings;

end

end

function feat_data = calc_am(peaks, onsets, fs, sig_data)

% eliminate any nans (which represent ectopics which have been removed)
peaks.t = peaks.t(~isnan(peaks.t));
peaks.v = peaks.v(~isnan(peaks.v));
onsets.t = onsets.t(~isnan(onsets.t));
onsets.v = onsets.v(~isnan(onsets.v));

% Find am
am.t = mean([onsets.t, peaks.t], 2);
am.v = [peaks.v - onsets.v];

% Normalise
feat_data.v = am.v./nanmean(am.v);
feat_data.t = am.t;
feat_data.fs = fs;

end

function feat_data = calc_bw(peaks, onsets, fs, sig_data)

% eliminate any nans (which represent ectopics which have been removed)
peaks.t = peaks.t(~isnan(peaks.t));
peaks.v = peaks.v(~isnan(peaks.v));
onsets.t = onsets.t(~isnan(onsets.t));
onsets.v = onsets.v(~isnan(onsets.v));

% Find bw
bw.v = mean([onsets.v, peaks.v], 2);
bw.t = mean([onsets.t, peaks.t], 2);

% Find am
am.t = mean([onsets.t, peaks.t], 2);
am.v = [peaks.v - onsets.v];

% Normalise
feat_data.v = bw.v./nanmean(am.v);
feat_data.t = bw.t;
feat_data.fs = fs;

end

function feat_data = calc_bwm(peaks, onsets, fs, sig_data)

% eliminate any nans (which represent ectopics which have been removed)
peaks.t = peaks.t(~isnan(peaks.t));
peaks.v = peaks.v(~isnan(peaks.v));
onsets.t = onsets.t(~isnan(onsets.t));
onsets.v = onsets.v(~isnan(onsets.v));

% Find bwm
bwm.t = mean([onsets.t(2:end), onsets.t(1:(end-1))], 2);
bwm.v = nan(length(peaks.t)-1,1);
for s = 1 : (length(onsets.t)-1)
    rel_sig_els = sig_data.t >= onsets.t(s) & sig_data.t < onsets.t(s+1);
    bwm.v(s) = mean(sig_data.v(rel_sig_els));
end

% Find am
am.t = mean([onsets.t, peaks.t], 2);
am.v = [peaks.v - onsets.v];

% Normalise
feat_data.v = bwm.v./nanmean(am.v);
feat_data.t = bwm.t;
feat_data.fs = fs;

end

function feat_data = calc_fm(peaks, onsets, fs, sig_data)

% find fm
fm.v = [peaks.t(2:end) - peaks.t(1:(end-1))]/fs;
fm.t = mean([peaks.t(2:end), peaks.t(1:(end-1))], 2);

% eliminate any nans (which represent ectopics which have been removed)
fm.t = fm.t(~isnan(fm.t));
fm.v = fm.v(~isnan(fm.v));

% Normalise
feat_data.v = fm.v./nanmean(fm.v);
feat_data.t = fm.t;
feat_data.fs = fs;

end

