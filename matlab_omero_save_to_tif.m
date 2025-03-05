% Storing your password in a file is 
% dangerous. Enter your details in the command window, connect, and then
% clear it using clc.
% Then run this script
%username='USER';
%password='PASS';

imageIDs=[884217, 884273];

servername='camdu.warwick.ac.uk';
client = loadOmero(servername);
session = client.createSession(username, password);

for i=1:length(imageID)
[image_name,stacks]=fetch_stack(session,imageIDs(i));
output_name=sprintf('%s.tif',image_name);
save_as_imagej_tif(stacks, output_name);
end

%Close session with OMERO
client.closeSession();

function save_as_imagej_tif(input, output_path)
    %input is multidimensional uint16 array of image stack with dimensions in
    %order sizeX,sizeY,sizeZ,sizeC,sizeT
    %output_path is where to save image (e.g. use 'test.tif' to save in current
    %direction
    MultiDimImg=input;

    fiji_descr = ['ImageJ=1.52p' newline ...
        'images=' num2str(size(MultiDimImg,3)*...
        size(MultiDimImg,4)*...
        size(MultiDimImg,5)) newline...
        'channels=' num2str(size(MultiDimImg,4)) newline...
        'slices=' num2str(size(MultiDimImg,3)) newline...
        'frames=' num2str(size(MultiDimImg,5)) newline...
        'hyperstack=true' newline...
        'mode=grayscale' newline...
        'loop=false' newline...
        'min=0.0' newline...
        'max=65535.0'];  % change this to 256 if you use an 8bit image

    t = Tiff(output_path,'w');
    tagstruct.ImageLength = size(MultiDimImg,1);
    tagstruct.ImageWidth = size(MultiDimImg,2);
    tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample = 16;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.Compression = Tiff.Compression.LZW;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.SampleFormat = Tiff.SampleFormat.UInt;
    tagstruct.ImageDescription = fiji_descr;
    for frame = 1:size(MultiDimImg,5)
        for slice = 1:size(MultiDimImg,3)
            for channel = 1:size(MultiDimImg,4)
                t.setTag(tagstruct)
                t.write(MultiDimImg(:,:,slice,channel,frame));
                t.writeDirectory(); % saves a new page in the tiff file
            end
        end
    end
    t.close()
end

function [image_name,stacks]=fetch_stack(session,imageID)
%session is an omero session
%imageID is the omero imageID to be downloaded and saved
    image = getImages(session,imageID);
    filename=image.getName().getValue();
    [~,image_name,~] = fileparts(string(filename));
    pixels = image.getPrimaryPixels();
    sizeX = pixels.getSizeX().getValue(); % The number of pixels along the X-axis.
    sizeY = pixels.getSizeY().getValue(); % The number of pixels along the Y-axis.
    sizeZ = pixels.getSizeZ().getValue(); % The number of z-sections.
    sizeT = pixels.getSizeT().getValue(); % The number of timepoints.
    sizeC = pixels.getSizeC().getValue(); % The number of channels.
    stacks=zeros(sizeX,sizeY,sizeZ,sizeC,sizeT,'uint16');
    for t=0:sizeT-1
        for c=0:sizeC-1
            stacks(:,:,:,c+1,t+1)=getStack(session, image, c, t);
        end
    end
end