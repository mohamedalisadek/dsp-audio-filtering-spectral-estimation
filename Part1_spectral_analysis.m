clear
close all
%% Part 1 
% Task1.1: Reading Audio File and Sampling Frequency.
[Y, Fs] = audioread("music_test_fayrouz.mp3");
Ymono = Y(:, 1);
% where Fs is the sample frequancy  = 32KHz and Y is the sampled output

% Task 1.2: Capturing Audio Segment.
% Select 3 secs from the center
ts = 1/Fs;
targetDur = 3; %3secs
numberOfSamples = targetDur * Fs;
center = floor(length(Y)/2);
halfSegment = floor(numberOfSamples/2);
startIdx = max(1, center - halfSegment);
endIdx = min(length(Y), center + halfSegment - 1);
signal = Y(startIdx:endIdx);
n = 0:length(signal)-1;
% time vector
t = n * ts;

% Task 1.3: Plotting Audio Signal vs. Time
figure;
plot(t, signal);
xlabel('Time (secs)');
ylabel('Amplitude');
title('Audio Signal Segment (3 seconds from center)');
grid on;

% Task 1.4: Generating Sinusoidal Interference
fi = 15.2e3; %tone freq
Ai = 1.8; % amplitude
interference = Ai*cos(2*pi*fi*t);
figure;
plot(t(1:100), interference(1:100));
xlabel('Time (secs)');
ylabel('Amplitude');
title('interference');
grid on;

% Task 1.5: Add the interference signal to the sigment
sig_total = signal + interference;
% before interference
%sound(signal, Fs)
% after interference
%sound(sig_total, Fs)

% Task 1.6
nfft_base = 2^9;
window_size_base = nfft_base; 
overlap_percentage_base = 0.5; 
num_overlap_base = floor(overlap_percentage_base * window_size_base);
window_func_base = @hanning;
window_name_base = 'Hanning';
window_vector_base = window_func_base(window_size_base);
Fps = Fs;

%% 1. Effect of Window Type
disp('Plotting: Effect of Window Type');
nfft_win = nfft_base;
window_win = nfft_win;
num_overlap_win = floor(overlap_percentage_base * window_win);

window_compare = {@rectwin, @hanning, @hamming, @blackman};
window_names = {'Rectangular', 'Hanning', 'Hamming', 'Blackman'};

figure;
for i = 1:length(window_compare)
    current_func = window_compare{i};
    current_name = window_names{i};
    current_vector = current_func(window_win);
    [PSD, Fpsd] = pwelch(sig_total, current_vector, num_overlap_win, nfft_win, Fps);
    subplot(length(window_compare), 1, i);
    plot(Fpsd, 10*log10(PSD));
    grid on;
    title(sprintf('%s Window', current_name));
    xlabel('Frequency (Hz)');
    ylabel('PSD (dB/Hz)');
end
sgtitle(sprintf('Effect of Window Type\nNFFT=%d, WinSize=%d, Overlap=%.0f%%, Fs=%d Hz', ...
                nfft_win, window_win, overlap_percentage_base*100, Fps));
saveas(gcf, 'Effect_Window_Type_Subplots.png');

%% 2. Effect of NFFT
disp('Plotting: Effect of NFFT');
nfft__test = [2^8, 2^10, 2^12];

figure;
for i = 1:length(nfft__test)
    current_nfft = nfft__test(i);
    current_size = current_nfft;
    current_num_overlap = floor(overlap_percentage_base * current_size);
    current_vector = window_func_base(current_size);
    [PSD, Fpsd] = pwelch(sig_total, current_vector, current_num_overlap, current_nfft, Fps);
    subplot(length(nfft__test), 1, i);
    plot(Fpsd, 10*log10(PSD));
    grid on;
    title(sprintf('NFFT=%d (WinSize=%d)', current_nfft, current_size));
    xlabel('Frequency (Hz)');
    ylabel('PSD (dB/Hz)');
end
sgtitle(sprintf('Effect of NFFT\nWindow: %s, Overlap=%.0f%%, Fs=%d Hz', ...
                window_name_base, overlap_percentage_base*100, Fps));
saveas(gcf, 'Effect_NFFT_Subplots.png');

%% 3. Effect of Window Size
disp('Plotting: Effect of Window Size');
nfft_winsize = nfft_base;
window_test = [0.25 * nfft_winsize, 0.5 * nfft_winsize, nfft_winsize];

figure;
for i = 1:length(window_test)
    current_win_size = window_test(i);
    current_num_overlap = floor(overlap_percentage_base * current_win_size);
    current_vector = window_func_base(current_win_size);
    [PSD, Fpsd] = pwelch(sig_total, current_vector, current_num_overlap, nfft_winsize, Fps);
    subplot(length(window_test), 1, i);
    plot(Fpsd, 10*log10(PSD));
    grid on;
    title(sprintf('WinSize = %.1f', current_win_size));
    xlabel('Frequency (Hz)');
    ylabel('PSD (dB/Hz)');
end
sgtitle(sprintf('Effect of Window Size\nNFFT=%d, Window: %s, Overlap=%.0f%%, Fs=%d Hz', ...
                nfft_winsize, window_name_base, overlap_percentage_base*100, Fps));
saveas(gcf, 'Effect_Window_Size_Subplots.png');

%% 4. Effect of Overlap Percentage
disp('Plotting: Effect of Overlap Percentage');
nfft_overlap = nfft_base;
win_size = nfft_overlap;
window_vector = window_func_base(win_size);
overlap_percentages_to_test = [0, 0.25, 0.5, 0.75];

figure;
for i = 1:length(overlap_percentages_to_test)
    current_overlap_perc = overlap_percentages_to_test(i);
    current_num_overlap = floor(current_overlap_perc * win_size);
    if current_num_overlap >= win_size && win_size > 0
        current_num_overlap = win_size - 1;
    end
    [PSD, Fpsd] = pwelch(sig_total, window_vector, current_num_overlap, nfft_overlap, Fps);
    subplot(length(overlap_percentages_to_test), 1, i);
    plot(Fpsd, 10*log10(PSD));
    grid on;
    title(sprintf('Overlap = %.0f%%', current_overlap_perc*100));
    xlabel('Frequency (Hz)');
    ylabel('PSD (dB/Hz)');
end
sgtitle(sprintf('Effect of Overlap Percentage\nNFFT=%d, WinSize=%d, Window: %s, Fs=%d Hz', ...
                nfft_overlap, win_size, window_name_base, Fps));
saveas(gcf, 'Effect_Overlap_Percentage_Subplots.png');

%% 5. Effect of Fs parameter in pwelch
disp('Plotting: Effect of Fs parameter passed to pwelch');
nfft_fs = nfft_base;
window_size_for_fs = nfft_fs;
window_fs_test = window_func_base(window_size_for_fs);
num_overlap_fs = floor(overlap_percentage_base * window_size_for_fs);
fs_params = [0.25 * Fs, 0.5 * Fs, Fs, 2 * Fs];

figure;
for i = 1:length(fs_params)
    current_fs_told_to_pwelch = fs_params(i);
    [PSD, F_scaled] = pwelch(sig_total, window_fs_test, num_overlap_fs, nfft_fs, current_fs_told_to_pwelch);
    subplot(length(fs_params), 1, i);
    plot(F_scaled, 10*log10(PSD));
    grid on;
    title(sprintf('pwelch Fs param = %.0f Hz', current_fs_told_to_pwelch));
    xlabel('Frequency (Hz)');
    ylabel('PSD (dB/Hz)');
end
sgtitle(sprintf('Effect of Fs Parameter in pwelch (True Fs = %d Hz)\nNFFT=%d, WinSize=%d, Window: %s, Overlap=%.0f%%', ...
                Fs, nfft_fs, window_size_for_fs, window_name_base, overlap_percentage_base*100));
saveas(gcf, 'Effect_Fs_Parameter_Subplots.png');
