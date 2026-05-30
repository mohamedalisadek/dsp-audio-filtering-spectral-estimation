clear
close all
%% Part 2 : the same as part 1 till task 1.5
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Task 2.1, 2.2, 2.3 -> in the report

%% Task 2.4

%Design filters using the provided functions
HdEquiripple_LP = filter1;
HdLeastSqr_LP = filter2;
HdWinBlackman_BS = filter3;
fvtool(HdEquiripple_LP,'Fs', Fs, 'Legend', 'on');
title('Comparison of Filter Frequency Responses');
fvtool(HdLeastSqr_LP,'Fs', Fs, 'Legend', 'on');
title('Comparison of Filter Frequency Responses');
fvtool(HdWinBlackman_BS, 'Fs', Fs, 'Legend', 'on');
title('Comparison of Filter Frequency Responses');


%% Task 2.5
proposed_filters_objects = {HdEquiripple_LP, HdLeastSqr_LP, HdWinBlackman_BS};
proposed_filters_names = {'Filter 1 (Equiripple LPF)', 'Filter 2 (LS LPF)', 'Filter 3 (Window BSF)'};
num_filters = length(proposed_filters_objects);

% --- Initialize Table for Criteria Measurements ---
% Criteria: OrderN, Att_Interference_dB, MaxPassRipple_dB, PreservedBW_Hz
criteria_measurements = table('Size', [num_filters, 5], ...
    'VariableTypes', {'string', 'double', 'double', 'double', 'double'}, ...
    'VariableNames', {'FilterName', 'OrderN', 'Att_Interference_dB', 'MaxPassRipple_dB', 'PreservedBW_Hz'});

N_freqz = 2^13; % Number of points for freqz analysis

fprintf('Measuring criteria for each filter...\n');
for i = 1:num_filters
    Hd_current = proposed_filters_objects{i};
    filter_name_current = proposed_filters_names{i};
    
    b_coeffs = Hd_current.Numerator;
    order_current = length(b_coeffs) - 1;
    
    % Measure Stopband Attenuation at target_interference_freq
    [h_response, f_hz_vec] = freqz(b_coeffs, 1, N_freqz, Fs);
    mag_db_vec = 20*log10(abs(h_response) + eps); % Add eps for stability if h_response is zero
    
    [~, idx_at_interference] = min(abs(f_hz_vec - fi));
    attenuation_at_interference = -mag_db_vec(idx_at_interference);
    if attenuation_at_interference < 0, attenuation_at_interference = 0; end

    % Measure Max Passband Ripple & Preserved Bandwidth (approximations based on filter design files)
    passband_ripple_pkpk = NaN;
    preserved_bw_hz = NaN;

    if strcmp(filter_name_current, 'Filter 1 (Equiripple LPF)')
        Fpass_filt1 = 14800; % From filter1.m design
        pass_idx = (f_hz_vec >= 0 & f_hz_vec <= Fpass_filt1);
        pass_mag_db_segment = mag_db_vec(pass_idx);
        if ~isempty(pass_mag_db_segment)
            pass_mag_db_segment_filtered = pass_mag_db_segment(pass_mag_db_segment > -200); % Avoid extremely deep nulls
            if ~isempty(pass_mag_db_segment_filtered)
                passband_ripple_pkpk = max(pass_mag_db_segment_filtered) - min(pass_mag_db_segment_filtered);
            end
        end
        preserved_bw_hz = Fpass_filt1;
        
    elseif strcmp(filter_name_current, 'Filter 2 (LS LPF)')
        Fpass_filt2 = 14700; % From filter2.m design
        pass_idx = (f_hz_vec >= 0 & f_hz_vec <= Fpass_filt2);
        pass_mag_db_segment = mag_db_vec(pass_idx);
        if ~isempty(pass_mag_db_segment)
            pass_mag_db_segment_filtered = pass_mag_db_segment(pass_mag_db_segment > -200);
             if ~isempty(pass_mag_db_segment_filtered)
                passband_ripple_pkpk = max(pass_mag_db_segment_filtered) - min(pass_mag_db_segment_filtered);
            end
        end
        preserved_bw_hz = Fpass_filt2;

    elseif strcmp(filter_name_current, 'Filter 3 (Window BSF)')
        Fc1_filt3 = 14.8e3; % Stopband edge 1 from filter3.m
        Fc2_filt3 = 15.6e3; % Stopband edge 2 from filter3.m
        % Passbands are approx 0-Fc1 and Fc2-Fs/2 for fir1 'stop'
        pass_idx_combined = (f_hz_vec <= Fc1_filt3 | f_hz_vec >= Fc2_filt3) & (f_hz_vec <= Fs/2);
        pass_mag_db_segment_combined = mag_db_vec(pass_idx_combined);
        
        if ~isempty(pass_mag_db_segment_combined)
            pass_mag_db_segment_combined_filtered = pass_mag_db_segment_combined(pass_mag_db_segment_combined > -200);
            if ~isempty(pass_mag_db_segment_combined_filtered)
                passband_ripple_pkpk = max(pass_mag_db_segment_combined_filtered) - min(pass_mag_db_segment_combined_filtered);
            end
        end
        preserved_bw_hz = Fc1_filt3 + (Fs/2 - Fc2_filt3); % Sum of two passbands
    end
    
    criteria_measurements(i,:) = {filter_name_current, order_current, attenuation_at_interference, passband_ripple_pkpk, preserved_bw_hz};
    fprintf('  %s: Order=%d, Att@%.1fkHz=%.2fdB, Ripple=%.4fdB, PreservedBW=%.0fHz\n', ...
        filter_name_current, order_current, fi/1000, attenuation_at_interference, passband_ripple_pkpk, preserved_bw_hz);
end
disp('Raw Criteria Measurements:');
disp(criteria_measurements);
fprintf('\n');

% --- Define Weights for Criteria (sum to 1.0) ---
% ** IMPORTANT: Adjust these weights based on your project priorities! **
% Format: [Weight_Order, Weight_Attenuation, Weight_Ripple, Weight_PreservedBW]
weights = [0.20, 0.45, 0.25, 0.5]; 
fprintf('Criteria Weights: Order=%.2f, Attenuation=%.2f, Ripple=%.2f, PreservedBW=%.2f\n\n', ...
    weights(1), weights(2), weights(3), weights(4));

% --- Normalize Scores (0 to 1) ---
normalized_scores = zeros(num_filters, length(weights));
% Extract values into a matrix for easier processing
criteria_values_matrix = [criteria_measurements.OrderN, ...
                          criteria_measurements.Att_Interference_dB, ...
                          criteria_measurements.MaxPassRipple_dB, ...
                          criteria_measurements.PreservedBW_Hz];
% Define whether a higher value is better for each criterion
is_higher_better = [false, true, false, true]; % false for Order, Ripple; true for Att, BW

for c = 1:length(weights) % Iterate through each criterion (column)
    current_criterion_values = criteria_values_matrix(:, c);
    min_val = min(current_criterion_values);
    max_val = max(current_criterion_values);
    
    if (max_val - min_val) == 0
        % If all filters have the same value for this criterion, normalized score is 1
        normalized_scores(:, c) = 1;
    else
        if is_higher_better(c)
            % Higher is better: (value - min) / (max - min)
            normalized_scores(:, c) = (current_criterion_values - min_val) / (max_val - min_val);
        else
            % Lower is better: (max - value) / (max - min)
            normalized_scores(:, c) = (max_val - current_criterion_values) / (max_val - min_val);
        end
    end
    
    % Handle cases for a single filter (its score should be 1 for all criteria)
    if num_filters == 1
        normalized_scores(:, c) = 1;
    end
end

% Special handling for NaN values if any (e.g., if ripple couldn't be measured for a filter)
% Assuming ripple is the 3rd criterion (column index 3)
normalized_scores(isnan(normalized_scores(:, 3)), 3) = 0; % Assign 0 score (penalty) for NaN ripple

% --- Calculate Utility Scores ---
% UtilityScore = sum of (normalized_score_for_criterion * weight_for_criterion)
utility_scores = sum(normalized_scores .* weights, 2); % Element-wise multiplication, then sum across rows

% --- Display Decision Matrix Table ---
decision_table = criteria_measurements; % Start with raw measurements
decision_table.NormScore_Order = normalized_scores(:,1);
decision_table.NormScore_Att = normalized_scores(:,2);
decision_table.NormScore_Ripple = normalized_scores(:,3);
decision_table.NormScore_BW = normalized_scores(:,4);
decision_table.UtilityScore = utility_scores;

disp('Decision Matrix:');
disp(decision_table);
fprintf('\n');

% --- Select Best Filter ---
[max_utility, best_filter_idx] = max(utility_scores);
% Retrieve the selected filter object and its name
Hd_selected = proposed_filters_objects{best_filter_idx};
selected_filter_name = proposed_filters_names{best_filter_idx};
selected_filter_order = criteria_measurements.OrderN(best_filter_idx); % Get order from table

fprintf('Based on the decision matrix, the selected filter is: %s (Order N = %d)\n', ...
    selected_filter_name, selected_filter_order);
fprintf('It has a utility score of: %.4f\n', max_utility);
fprintf('Selected filter details from the decision table:\n');
disp(decision_table(best_filter_idx,:));

%% Task 2.6

b_coeffs = Hd_selected.Numerator;
% The denominator for an FIR filter is 1.
a_coeffs = 1;
signalFiltered = filter(b_coeffs, a_coeffs, sig_total);

nfft_comp = 2^12;        
window_comp = hanning(nfft_comp);

num_comp = floor(0.5 * nfft_comp);
%Calculate PSD for the signal with interference (sig_total) 
[PSD_sig_total, Fpsd_sig_total] = pwelch(sig_total,window_comp,num_comp,nfft_comp, Fs);
% Calculate PSD for the filtered signal 
[PSD_filtered, Fpsd_filtered] = pwelch(signalFiltered,window_comp,num_comp,nfft_comp,Fs);

figure;

%  PSD of signal + interference (before filtering)
subplot(2, 1, 1);
plot(Fpsd_sig_total, 10*log10(PSD_sig_total + eps)); 
grid on;
title('PSD: Signal (Before Filtering)');
xlabel('Frequency (Hz)');
ylabel('PSD (dB/Hz)');

% PSD of filtered signal
subplot(2, 1, 2);
plot(Fpsd_filtered, 10*log10(PSD_filtered + eps));
grid on;
title('PSD: Filtered Signal');
xlabel('Frequency (Hz)');
ylabel('PSD (dB/Hz)');
sgtitle('PSD Comparison: Before and After Filtering');


