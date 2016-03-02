function [minInt maxInt] = getMinMaxIntensity(imres, imblob, id, tracer)
%%
% 'imres' is the farsight results image stack
% 'imblob' is image stack of the channel to be measured
% 'id' is the optional list of cell IDs.  If not given,
% they are determined from the results image.
%
% LM, Nov2013
n = length(id);
minInt = zeros(n,1);
maxInt = zeros(n,1);

tic
imnuc = read_multitiff(imres,'int');
if isempty(imnuc)
    fprintf('Could not open nuclei image \n', imres);
    return
end

img = read_multitiff(imblob,'int');
if isempty(img)
    fprintf('Could not open channel image \n', imblob);
    return
end
%{
if nargin < 3
    fprintf('\nGetting cell IDs from results image\n');
    id = farsight_get_id_from_image(imres);
    fprintf('Got IDs\n');
end
%}

fprintf('\nComputing min/max ...\n');
for i = 1:n
    if tracer(i)
        ix = (imnuc == id(i));
        x = double(img(ix));
        minInt(i,1) = min(x);
        maxInt(i,1) = max(x);
    end
end
fprintf('Done.  Took %d min.\n', round(toc/60));