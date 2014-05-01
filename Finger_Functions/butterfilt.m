function [ filtered_data ] = butterfilt( data,order,cutfreq,srate )
% Forward and backward filter data
% order : n-th order digitial butterworth filter
% cutfreq : low pass cut off frequency
% srate : acquisition sampling rate

[B,A]=butter(order,cutfreq/(srate/2));

filtered_data=zeros(256,size(data,2));
for i=1:256;
    filtered_data(i,:)=filtfilt(B,A,data(i,:));
end

end

% Author: Jennifer Wu, March 2012
% Last debug: Jennifer Wu, 03-08/2012