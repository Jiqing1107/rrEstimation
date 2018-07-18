load('mimicii_data.mat');

% frequency at which to sample filter-based respiratory signals
filt_resample_fs = 25;
% frequency at which to resample feature-based respiratory signals
feat_resample_fs = 5;

vlf_fpass = 0.157;  % in Hz
vlf_fstop = 0.02;   % in Hz
vlf_dpass = 0.05;
vlf_dstop = 0.01;

vhf_fpass = 38.5;  % in HZ
vhf_fstop = 33.12;  % in HZ  
vhf_dpass = 0.05;
vhf_dstop = 0.01;

sub_cardiac_fpass = 0.63;  % in Hz
sub_cardiac_fstop = 0.43;
sub_cardiac_dpass = 0.05;
sub_cardiac_dstop = 0.01;

subj_list = 1;

for subj = subj_list
    
    % stage 1: EHF (eliminate high frequency)
    s = data(subj).ppg.v;
    
    s_ehf.fs = data(subj).ppg.fs;
    s_ehf.v = elim_vhfs(s, s_ehf.fs, vhf_fpass, vhf_fstop, vhf_dpass, vhf_dstop);
    s_ehf.t = (1/s_ehf.fs)*(1:length(s_ehf.v));
    
    % stage 2: PDT
    s = s_ehf;
    fs = s_ehf.fs;
    
    pdt = elim_sub_cardiac(s, sub_cardiac_fpass, sub_cardiac_fstop, sub_cardiac_dpass, sub_cardiac_dstop, filt_resample_fs);
    
    [peaks,onsets] = IMS(pdt, fs);
    
    %Save segmentation results 
    sr.fs = fs;
    sr.p.v = s.v(peaks);    % peak value
    sr.p.t = s.t(peaks);    % peak time
    sr.tr.v = s.v(onsets);  % onset value
    sr.tr.t = s.t(onsets);  % onset time
    sr.timings.t_start = s.t(1);
    sr.timings.t_end = s.t(end);

    % Stage 3: FPt
    rel_data.beats = sr;
    rel_data.s = s;
    rel_data.fs = fs;
    rel_data.timings = sr.timings;

    % PPG Peaks
    s_fpt = FPt(rel_data);

    % Stage 4: FMe
    s_fme = FMe(s, s_fpt);
    
    % Stage 5: RS
    s_rs = lin(s_fme, feat_resample_fs);
    s_rs.fs = fs;
    try
       s_rs = bpf_signal_to_remove_non_resp_freqs(s_rs, s_rs.fs, vlf_fpass, vlf_fstop, vlf_dpass, vlf_dstop);
    catch
       % if there aren't enough samples, then don't BPF:
       s_rs = s_rs;
    end
    
     % Stage 6: ELF (eliminate low frequency)
     s_elf.t = s_rs.t;
     try
        s_elf.v = elim_vlfs(s_rs, up);
     catch
        % if there aren't enough points to use the filter, simply carry forward the previous data
       s_elf.v = s_rs.v;
     end
     s_elf.fs = s_rs.fs;


end   
    
    
    
    
    
    
    
    