load('mimicii_data.mat');

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

subj_list = 1:length(data);

for subj = subj_list
    
    s = data(subj).ppg.v;
    
    ehf.fs = data(subj).ppg.fs;
    ehf.v = elim_vhfs(s, ehf.fs, vhf_fpass, vhf_fstop, vhf_dpass, vhf_dstop);
    ehf.t = (1/ehf.fs)*(1:length(ehf.v));
    
    s = ehf;
    fs = ehf.fs;
    
    pdt = elim_sub_cardiac(s, sub_cardiac_fpass, sub_cardiac_fstop, sub_cardiac_dpass, sub_cardiac_dstop);
    
    [peaks,onsets] = IMS(pdt, fs);
    
    %Save segmentation results 
    sr.fs = fs;
    sr.p.v = s.v(peaks);
    sr.p.t = s.t(peaks);
    sr.tr.v = s.v(onsets);
    sr.tr.t = s.t(onsets);
    sr.timings.t_start = s.t(1);
    sr.timings.t_end = s.t(end);
    
    
    
    
    
    
    
    
    