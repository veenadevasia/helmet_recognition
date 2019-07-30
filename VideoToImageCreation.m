clc;
clear all;
close all;

% Browse Video File :
[ video_file_name,video_file_path ] = uigetfile({'*.wmv;*.mp4;*.avi'});
if(video_file_path==0)
    return;
end
% Output path
output_image_path = fullfile(video_file_path,video_file_name(1:strfind(video_file_name,'.')-1));
mkdir(output_image_path);

input_video_file = [video_file_path,video_file_name];
% Read Video
videoFReader = vision.VideoFileReader('Filename',input_video_file,'PlayCount',1);
count = 1;

while ~isDone(videoFReader)
    key_frame = step(videoFReader);
    imwrite(key_frame,fullfile(output_image_path,[num2str(count),'.png']));
    count = count + 1;
end
% Release video object
release(videoFReader);

disp('COMPLETED... (-_-)');