function [peaks,onsets] = IMS(s_filt,fs)

[peaks,onsets,artifs] = adaptPulseSegment(s_filt.v,fs);

end