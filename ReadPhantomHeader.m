function Header_Info = ReadPhantomHeader(File_name)
%% Function to read Phantom header file info
% Written by Anirudh Thuppul 04/20/2020
% Last edited by Anirudh Thuppul 04/27/2020
% Input:
% - File_name: xml format header file name
% Output: Object Header_Info containing video file information
% - Header_Info.File_name: Header file name
% - Header_Info.Num_frames: Number of frames in video
% - Header_Info.Date: Date video was recorded
% - Header_Info.Frame_width: Pixel width of video frames
% - Header_Info.Frame_height: Pixel height of video frames
% - Header_Info.Bit_depth: Bit depth of video frames
% - Header_Info.Fps: Frame rate of video
% - Header_Info.Shutter_rate: Shutter rate of video
% - Header_Info.Duration: Duration time of video

% Read file and load parent/childs
Main_parent = xmlread(File_name);
Header_Info.File_name = File_name(1:end-4);
Child_1 = Main_parent.item(1).getChildNodes;

% Video Info
Child_2 = Child_1.item(0).getChildNodes;
Header_Info.Num_frames = str2double(Child_2.item(6).getFirstChild.getData);
Child_3 = Child_2.item(7).getChildNodes;
Header_Info.Date = char(Child_3.item(0).getFirstChild.getData);
Child_4 = Child_1.item(2).getChildNodes;
Header_Info.Fps = str2double(Child_4.item(27).getFirstChild.getData);
Header_Info.Shutter_rate = str2double(Child_4.item(74).getFirstChild.getData)*10^-9;
Header_Info.Duration = Header_Info.Num_frames./Header_Info.Fps;

% Frame Info
Child_5 = Child_1.item(1).getChildNodes;
Header_Info.Frame_width = str2double(Child_5.item(1).getFirstChild.getData);
Header_Info.Frame_height = str2double(Child_5.item(2).getFirstChild.getData);
Header_Info.Bit_depth = str2double(Child_5.item(4).getFirstChild.getData);

end