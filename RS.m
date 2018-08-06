function resampled_data = RS(sig_data, resample_fs, elim_vlf_param, elim_hf_param)
%RS resamples feat-based respiratory signals at a regular sampling rate.
fs_orig = sig_data.fs;
feat_data = sig_data;

%% Resample waveform
fs = resample_fs;
resampled_data = lin(feat_data, fs, fs_orig);
resampled_data.fs = fs;
% BPF if specified by option
try
    resampled_data = bpf_signal_to_remove_non_resp_freqs(resampled_data, resampled_data.fs, elim_vlf_param, elim_hf_param);
catch
    % if there aren't enough samples, then don't BPF:
    resampled_data = resampled_data;
end
end

function resampled_data = lin(feat_data, fs, fs_orig)

if length(feat_data.t) <2
    resampled_data.t = nan;
    resampled_data.v = nan;
    return
end

resampled_data.t = feat_data.t(1):(1/fs):feat_data.t(end);
resampled_data.v = interp1(feat_data.t, feat_data.v, resampled_data.t, 'linear');

end