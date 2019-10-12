%% FSK project
clear
close all
%% Signal Parameters
M = 2;
k = log2(M); % bits per symbol
fc = 300; % Carrier Frequency (Hz)
Fsym = 500; % Symbol Rate (symbols/ 1 second)
sps = 100; % Samples per symbol
fs = Fsym*sps; % samples per second
Tsym = 1/Fsym; % Symbol duration (seonds/ 1 symbol)
deltaF = M/Tsym; % signal frequency spacing
Eb = 0.01;  % Energy per bit
Es = Eb*k; % Energy per symbol
numBits = 10; % number of bits
data = randi([0 1],1,numBits); % random data
numSymbols = numBits/k; % number of symbols
t = (0:1:numSymbols*sps-1)/fs; % timing vector
phiOnOff = false; % random phase offset per symbol

%% Convert Bits to Symbols to generate Baseband PAM Signal
symbols = bits2Symbols(data,M);

%% Generate Signal
fskSig = NaN(1,numSymbols*sps);
amp = sqrt(2*Es/Tsym);
for idx = 1:numSymbols
    phi = phiOnOff*rand*2*pi; % random phase
    tSym = t((sps*(idx-1)+1):sps*idx); % time vector when symbol occurs
    modSym = fskmodulator(M,symbols(idx),deltaF,fc,tSym,amp,phi);
    fskSig((sps*(idx-1)+1):sps*idx) = modSym;
end

figure(1)
plot(t,real(fskSig))
hold on
x = (1:numSymbols).'*[Tsym Tsym];
y = repmat([-amp amp],numSymbols,1);
for index = 1:numSymbols
plot(x(index,:),[y(index,1) y(index,2)],'--k','linewidth',0.5)
end
ylim([-amp amp])
xlabel('time (s)')
ylabel('amplitude (volts)')
title('FSK signal')

figure(2)
nFFT = 2^20;
freq = linspace(-fs/2,fs/2,nFFT);
plot(freq,fftshift(abs(fft(fskSig,nFFT))));
xlabel('Frequency (Hz)')
ylabel('Magnitude')
title('Frequency Spectrum')


snr = 10;
N0 = 1/((10^(snr/10)));
noise = randn(1,numel(fskSig)).*sqrt(N0/2)+...
    (j*randn(1,numel(fskSig)).*sqrt(N0/2));

noisySig = fskSig + noise;
plot(t,real(noisySig))

choice1 = max(abs(xcorr(noisySig(sps+1:sps+sps),amp*cos(2*pi*(fc)*t(sps+1:sps+sps) - 0))))
choice2 = max(abs(xcorr(noisySig(sps+1:sps+sps),amp*cos(2*pi*(fc-deltaF)*t(sps+1:sps+sps) - 0))))

