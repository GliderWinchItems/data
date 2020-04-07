clear all
clc

%   From control law file
Hz = 64         %   polling rate
Kp = 0.1        %   proportional gain 
Ki = 1e-3       %   integral gain      
MxCmdTrq = 100  %   Maximum absolute commanded torque
MxIntTrq = 10   %   Maximum absolute integral torque


M = csvread('log200328.csv', 1, 0);    %   read file skipping first line

%   make entries before first payload Nans
for i = 1:size(M,2)
    indx = find(M(:, i));
    if ~isempty(indx) 
        indx = indx(1);
    end    
    M(1:(indx - 1), i) = NaN;
end

%   unwrap time values
t = (round(unwrap((M(:, 1) - Hz/2) * (2 * pi / Hz ))...
    * Hz/ (2 * pi) + Hz / 2) - M(1, 1)) / Hz;

%   Start and stop times for display period selection
timstrt = 0
% timstp = max(t)
timstp =65

% timstrt = 51
% timstp = 53


%   display speeds and torques
figure(1)
clf

%   infer proportional and integral components

ds = M(:, 30);      %   desired speed
as = M(:, 5);       %   actual speed
ct = M(:, 2) * 0.1; %   commanded torque
spderr = ds - as;   %   speed error;
cp = spderr * Kp;   %   proportional torque
ci = ct - cp;       %   integral torque

%   Integral componet is clipped at min and max values but is suspect due
%   to comand torque clipping
indx = find(cp > MxCmdTrq + MxIntTrq);
ci(indx) = MxIntTrq;
indx = find(cp < -MxCmdTrq  - MxIntTrq);
ci(indx) = -MxIntTrq;

%   Display speeds
subplot(2, 1, 1)
plot(t, [ds, as, spderr], 'linewidth', 1.5)
ylabel('Speed (RPM)')
title('Speeds')
xlim([timstrt timstp])
legend('Desired Speed', 'Actual Speed', 'Speed Error', 'location', 'best')
grid on
zoom on


%   display torques
subplot(2, 1, 2)
plot(t, [ct, M(:, 3)], 'linewidth', 1.5)
hold on
plot(t, cp, 'r--', 'linewidth', 1.5)
plot(t, ci, 'c--', 'linewidth', 1.5)
xlabel('Time (s)')
ylim([-MxCmdTrq - 25, MxCmdTrq + 25])


ylabel('Torques (Nm)')
xlim([timstrt timstp])
title('Torques')
legend('Command', 'Actual', 'Proportional', 'Integral', 'location', 'best')
grid on
zoom on

%   Supply Voltages, Currents, and Power
figure(2)
clf

subplot(3, 1, 1)
plot(t, M(:, [6 10 7]), 'linewidth', 1.5)
ylabel('Voltage (V)')
xlim([timstrt timstp])
title(' Supply Voltages and Currents')
legend('Battery at Contactor', 'DMOC+ at Contactor', 'DMOC Reported', 'location', 'best')
grid on
zoom on

subplot(3, 1, 2)
plot(t, M(:, 8:9), 'linewidth', 1.5)
xlabel('Time (s)')
ylabel('Current (amps)')
legend('Contactor',  'DMOC', 'location', 'best')
xlim([timstrt timstp])
grid on
zoom on

subplot(3, 1, 3)
pwr = M(:, 10) .* M(:, 8) /1000;
plot(t, pwr, 'linewidth', 1.5)
xlabel('Time (s)')
ylabel('Power (kW)')

xlim([timstrt timstp])
grid on
zoom on


%   Plot temperatures
figure(3)
clf

plot(t, M(:, 14:16), 'linewidth', 1.5)
xlabel('Time (s)')
ylabel('Temperature (C)')
grid on
legend('Rotor', 'Inverter', 'Stator', 'psotion', 'best')
title('Temperatures')
xlim([timstrt timstp])


%   DQ Voltages and Currents
figure(4)
clf

subplot(2, 1, 1)

indx = find(M(:, 20) < -(2^15)/100);
M(indx, 20) = M(indx, 20) + (2^16)/100;
M(:, 18) = M(:, 18) + 9;    %   offset refinement

plot(t, M(:, [18 20]), 'linewidth', 1.5)
ylabel('Voltage (V)')
xlim([timstrt timstp])
title('DQ Voltages and Currents')
legend('D', 'Q','location', 'best')
grid on
zoom on

subplot(2, 1, 2)
plot(t, M(:, [19, 21]), 'linewidth', 1.5)
xlabel('Time (s)')
ylabel('Current (amps)')
legend('D', 'Q','location', 'best')
xlim([timstrt timstp])
grid on
zoom on

%   What figure to display when script completes
figure(2)

