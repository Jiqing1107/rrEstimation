load('mimicii_data.mat');
addpath(genpath('./'));
% frequency at which to sample filter-based respiratory signals
filt_resample_fs = 25;
% frequency at which to resample feature-based respiratory signals
feat_resample_fs = 5;

elim_vlf_param.Fpass = 0.157;  % in Hz
elim_vlf_param.Fstop = 0.02;   % in Hz
elim_vlf_param.Dpass = 0.05;
elim_vlf_param.Dstop = 0.01;

elim_vhf_param.Fpass = 38.5;  % in HZ
elim_vhf_param.Fstop = 33.12;  % in HZ  
elim_vhf_param.Dpass = 0.05;
elim_vhf_param.Dstop = 0.01;

% Filter characteristics: Eliminate HFs (above resp freqs)
elim_hf_param.Fpass = 1.2;  % in Hz
elim_hf_param.Fstop = 0.8899;  % in Hz     (1.2 and 0.8899 provide a -3dB cutoff of 1 Hz)
elim_hf_param.Dpass = 0.05;
elim_hf_param.Dstop = 0.01;

sub_cardiac_fpass = 0.63;  % in Hz
sub_cardiac_fstop = 0.43;
sub_cardiac_dpass = 0.05;
sub_cardiac_dstop = 0.01;

subj_list = 1;

for subj = subj_list
    
    % stage 1: EHF (eliminate high frequency)
    s = data(subj).ppg.v;
    
    s_ehf.fs = data(subj).ppg.fs;
    s_ehf.v = elim_vhfs(s, s_ehf.fs, elim_vhf_param);
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
    s_rs = RS(s_fme, feat_resample_fs, elim_vlf_param, elim_hf_param);
    
     % Stage 6: ELF (eliminate low frequency)
     s_elf = ELF(s_rs, elim_vlf_param);

end   
    
    
    
    
    
    
    
    