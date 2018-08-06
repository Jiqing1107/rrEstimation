function hpfilt = ELF(sig_data, elim_vlf_param)
%% Eliminate VLFs
hpfilt.t = sig_data.t;
try
    hpfilt.v = elim_vlfs(sig_data, elim_vlf_param);
catch
    % if there aren't enough points to use the filter, simply carry forward the previous data
    hpfilt.v = sig_data.v;
end
hpfilt.fs = sig_data.fs;