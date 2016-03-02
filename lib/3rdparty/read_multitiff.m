function im = read_multitiff(fname,imtype)
%
% function im = read_multitiff(fname,imtype)
%
% Reads a tiff image that contains multiple slices or a folder with
% multiple tiff files and puts them into a stack.  Works on a single
% colour channel.
%
% 'fname' is the name of a multi-page tiff file or it can be one of 
% 'r' 'g' 'b' if you are in a folder that contains multiple tiff files 
% that make up a stack.  r,g,b, determines which channel is read from
% the tiff files.
%
% 'imtype' is a string specifying data type to return, it can be:
% 'short', 'uint8' both return byte images [0 255]
% 'int', 'uint16' both return uint images [0 65535]
% If not specified, default is 'uint8'
% The farsight results image is 'int'
%
% ME Jan 2013

im = [];

% LM, 7Mar2013
if ~exist(fname,'file'), disp(['Can''t find file ' fname]); return; end
%

if nargin < 2
    imtype = 'uint8';
elseif strcmp(imtype,'short')
    imtype = 'uint8';
elseif strcmp(imtype,'int')
    imtype = 'uint16';
end

if strcmp(fname,'r') || strcmp(fname,'g') || strcmp(fname,'b')
    isadir = 1;
    ch = find('rgb'==fname);
    dlist = dir('*.tif');
    fnames = {dlist(:).name};
    fname = fnames{1};
else
    isadir = 0;
end

info = imfinfo(fname);
info = info(1);
w = info.Width;
h = info.Height;

z = 0;
if isadir
    z = length(fnames);
else
    if isfield(info,'PageNumber')
        z = info.PageNumber(2);
    elseif isfield(info,'ImageDescription')
        s = info.ImageDescription;
        ix = strfind(s,'slices');
        if ix
            s = s(ix+7:end);
            ix = find(s==10,1,'first');
            z = str2double(s(1:ix));
        end
    end
end
% LM, Nov2013
if ~isfield(info,'Depth')
        z = 1;
end
%
if ~z
    fprintf('Could not determine number of z-slices\n');
    return
end

im = zeros(h,w,z,imtype);

for i = 1:z
    if isadir
        tmp = imread(fnames{i});
        im(:,:,i) = tmp(:,:,ch);
    else
        im(:,:,i) = imread(fname,'Index',i);
    end
end