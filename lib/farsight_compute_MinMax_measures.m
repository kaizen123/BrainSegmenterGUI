function [minInt maxInt] = farsight_compute_MinMax_measures(imres, imblob, id)
%
% [avg,total,fano,tail,skew,spars] = farsight_compute_measures(imres, imblob, id)
%
% Calculates the following measures of IEG expression within nuclei:
%
% total = sum of pixel intensities in nuclei
% avg = average pixel intensity
% fano = Fano factor = var/mean
% tail = mean intensity value of top 0.1% of histogram
% skew = skewness of histogram
% sparsity = measure of how diffuse the intensity is in the nucleus (larger
% values indicate intensity is diffuse)
%
% 'imres' is the farsight results image stack
% 'imblob' is image stack of the channel to be measured
% 'id' is the optional list of cell IDs.  If not given,
% they are determined from the results image.
%
% ME Jan, 2013
% BC Jan, 2013 added sparsity, total, average measures
% LM Nov2013, get MinMax intensity

tic
if nargin < 3
    fprintf('\nGetting cell IDs from results image\n');
    id = farsight_get_id_from_image(imres);
    fprintf('Got IDs\n');
end
n = length(id);
fprintf('There are %d cells\n',n);
minInt = zeros(n,1);
maxInt = zeros(n,1);

fprintf('\nComputing IEG expression measurements...\n');
m1 = floor(n/8);
m2 = mod(n,8);
for k = 0:m1-1
parpool('local', 8)
m0 = k*8+1;
mN = m0+7;
parfor i = m0:mN
    ix = (imres == id(i));
    x = double(imblob(ix));
    minInt(i) = min(x);
    maxInt(i) = max(x);
end
delete(gcp)
fprintf('Done for j= %d. Took %d min.\n', num2str(mN), round(toc/60));
end
parpool('local', m2)
m0 = k*8+1;
parfor i = m0:m2
    ix = (imres == id(i));
    x = double(imblob(ix));
    minInt(i) = min(x);
    maxInt(i) = max(x);
end
delete(gcp)

fprintf('Done.  Took %d sec.\n', round(toc));