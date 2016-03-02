function farsight_results_append(fname,colname,c)
%
% farsight_append_table(fname,colname,c)
%
% Appends columns of data to the farsight results table
%
% 'fname' is the name of the results table.
% A new file is created for the new table with 'edit' appended to 'fname' 
% 
% 'colname' is the text name for the column.
% If the number of columns is more than 1, colname must be a cell array
% otherwise colname can be cell array of 1 or a regular string
%
% 'c' is the data to append and should be in columns (ncell x nmeasure) 
% 
% ME Jan, 2013

ncol = size(c,2);
if ischar(colname)
    if ncol > 1
        fprintf('colname must be cell array\n');
        return
    else
        colname = {colname};
    end
else
    if length(colname) ~= ncol
        fprintf('number of columns and number of names dont match\n');
        return
    end
end

i = strfind(fname,'.txt');
if isempty(i)
    fntmp = [fname '_edit.txt'];
else
    fntmp = [fname(1:i-1) '_edit.txt'];
end
fid = fopen(fname,'r');
if fid < 0
    fprintf('Could not open results table\n');
    return
end

fgetl(fid);
n = 0;
while ischar(fgetl(fid))
    n = n + 1;
end
if n ~= size(c,1)
    fprintf('Data to append differs in length from file\n');
    fprintf('File has %d measures, data has %d\n',n,length(c));
    fclose(fid);
    return
end

ftmp = fopen(fntmp,'w');
if ftmp < 0 
    fprintf('Could not creat new file, try deleting the file %s\n',fntmp);
    fclose(fid);
    return
end

fseek(fid,0,'bof');
s = fgetl(fid);
if s(end) == sprintf('\t')
    t = '';
else
    t = '\t';
end
scol = sprintf('%s\t',colname{:});
fprintf(ftmp,['%s' t '%s\r\n'], s, scol);

f = [];
for i = 1:ncol
    if mean(c(:,i)) > 10
        f = [f '%.2f\t'];
    else
        f = [f '%.4f\t'];
    end
end

for i = 1:n
    s = fgetl(fid);
    fprintf(ftmp,['%s' t f '\r\n'],s,c(i,:));
end
fclose(fid);
fclose(ftmp);