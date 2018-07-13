function temp = FPt(rel_data)
%FPT detects Fiducial Points from PPG peak and trough annotations
% rel_data.beats
%         .s
%         .fs
%         .timings
%% Identify Fiducial Points

%% PPG Peaks
% Find peaks as max between detected onsets
temp.p_max.t = nan(length(rel_data.beats.tr.t)-1,1);
temp.p_max.v = nan(length(rel_data.beats.tr.t)-1,1);
for beat_no = 1 : (length(rel_data.beats.tr.t)-1)
    rel_range = find(rel_data.s.t >= rel_data.beats.tr.t(beat_no) & rel_data.s.t < rel_data.beats.tr.t(beat_no+1));
    [~, rel_el] = max(rel_data.s.v(rel_range));
    temp.p_max.t(beat_no) = rel_data.s.t(rel_range(rel_el));
    temp.p_max.v(beat_no) = rel_data.s.v(rel_range(rel_el));
end

%% PPG Troughs

% Find troughs as min between detected peaks
temp.tr_min.t = nan(length(temp.p_max.t)-1,1);
temp.tr_min.v = nan(length(temp.p_max.t)-1,1);
for beat_no = 1 : (length(temp.p_max.t)-1)
    rel_range = find(rel_data.s.t >= temp.p_max.t(beat_no) & rel_data.s.t < temp.p_max.t(beat_no+1));
    [~, rel_el] = min(rel_data.s.v(rel_range));
    temp.tr_min.t(beat_no) = rel_data.s.t(rel_range(rel_el));
    temp.tr_min.v(beat_no) = rel_data.s.v(rel_range(rel_el));
end
        
% Carry forward detected peaks and onsets
temp.det_p.t = rel_data.beats.p.t;
temp.det_p.v = rel_data.beats.p.v;
temp.det_tr.t = rel_data.beats.tr.t;
temp.det_tr.v = rel_data.beats.tr.v;
        
% carry forward fs and timings
temp.fs = rel_data.fs;
temp.timings = rel_data.timings;

end