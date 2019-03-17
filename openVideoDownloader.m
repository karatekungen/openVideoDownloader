function openVideoDownloader()
%Download any video serie from https://video.adm.ntnu.no
%Written by Adam Joseph Zinafrazi
clc
clear

%INPUT FROM USER
fprintf('***Data needed from user***\n')
series = input('Enter link to video series, (i.e. https://video.adm.ntnu.no/serier/4fe2d4d3dbfa0): ','s'); 
folderName = input('Enter name of folder to save the videos in, (i.e. TMA4100): ','s');

[~, ~, ~] = mkdir(lower(folderName));
savePath = ['./' lower(folderName) '/'];
temptxt = 'temp.txt';
fid = fopen(temptxt,'w');
fprintf(fid, webread(series));
fclose(fid);

findLink = '</small><a href="';
findTitle = '><h5>';
endTitle = '</h5></div>';
fid = fopen(temptxt, 'r');
list = {};
c = 0;
while ~feof(fid)
    line = fgetl(fid);
    if contains(line, '<small><i class="fi-calendar"></i>')
        c = c+1;
        list{c,2} = line(strfind(line,findLink)+length(findLink):end-2);     %video
        fgetl(fid); fgetl(fid);
        line = fgetl(fid);                          %line with title
        list{c,1} = line(strfind(line,findTitle)+length(findTitle):end-length(endTitle)); %title
    end
end
fclose(fid); delete(temptxt);

list = flip(list);
fid = fopen([savePath 'readme.txt'],'w');
for i = 1:size(list,1)
    fprintf(fid,'%d\t%s\t%s\n\n', i, list{i,1}, list{i,2});
    fprintf('%d)\t%s\n',i,list{i,1});
end
fclose(fid);
fprintf('\nThere are %d videos\n',size(list,1));
if size(list,1) == 0
    return
end
options = {'Download a specific video', 'Download all videos', 'Download from and to'};
fprintf('***What would you like to do?***\n')
for i = 1:size(options,2)
    fprintf('\t%d)\t%s\n',i,options{i});
end
fprintf('\t');
action = input('Enter option: ');

start = 0; last = 0;
switch action
    case 1
        start = input('Enter video number to download: ');
        last = start;
    case 2
        start = 1;
        last = size(list,1);
    case 3
        start = input('Enter video number to start from: ');
        last = input('Enter video number last video to be included: ');
end

fprintf('Downloading video %d to %d...\n',start,last);
for i = start:last
    fprintf('%d...',i)
    websave([savePath num2str(i)], enterVideo(list{i,2}));
end
fprintf('\nDownload complete!\n');
end

%**** helper function ****
function directURL = enterVideo(url)
source = webread(url);
startLine = '{ file: "';
endLine = '", label:';
pos1 = strfind(source, startLine);
pos2 = strfind(source, endLine);
version = size(pos1,2);

start = pos1(version)+length(startLine);
ending = pos2(version)-1;
directURL = source(start:ending);

if isempty(directURL) %HD does not exist, hence pick SD
    start = pos1(1)+length(startLine);
    ending = pos2(1)-1;
    directURL = source(start:ending);
end
end

