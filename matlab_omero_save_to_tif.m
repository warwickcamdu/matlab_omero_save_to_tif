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

for i=1:length(imageIDs)
[image_name,stacks,metadata]=fetch_stack(session,imageIDs(i));
output_name=sprintf('%s.ome.tif',image_name);
save_as_ome_tif(stacks, output_name,metadata);
end

%Close session with OMERO
client.closeSession();

function save_as_ome_tif(input, output_path, metadata)    
bfsave(input, output_path, 'metadata', metadata);
end

function [image_name,stacks,metadata]=fetch_stack(session,imageID)
%session is an omero session
%imageID is the omero imageID to be downloaded and saved
    image = getImages(session,imageID);
    filename=image.getName().getValue();
    [~,image_name,~] = fileparts(string(filename));

    pixels = image.getPrimaryPixels();
    % Get pixel resolution (voxel size in micrometers)
    voxelX = pixels.getPhysicalSizeX().getValue();
    voxelY = pixels.getPhysicalSizeY().getValue();
    % Z-resolution might be missing in some datasets
    voxelZ = NaN;  % Default to NaN if unavailable
    if ~isempty(pixels.getPhysicalSizeZ())
        voxelZ = pixels.getPhysicalSizeZ().getValue();
    end

    sizeX = pixels.getSizeX().getValue(); % The number of pixels along the X-axis.
    sizeY = pixels.getSizeY().getValue(); % The number of pixels along the Y-axis.
    sizeZ = pixels.getSizeZ().getValue(); % The number of z-sections.
    sizeT = pixels.getSizeT().getValue(); % The number of timepoints.
    sizeC = pixels.getSizeC().getValue(); % The number of channels.
    stacks=zeros(sizeX,sizeY,sizeZ,sizeC,sizeT,'uint16');
    [store, pixels] = getRawPixelsStore(session, image);
    for z = 0 : sizeZ - 1
        for c = 0 : sizeC - 1
            for t = 0 : sizeT - 1
            stacks(:,:,z+1,c+1,t+1) = getPlane(pixels, store, z, c, t);
            end
        end
    end
    channels = loadChannels(session, image);
    store.close();
    
    metadata = createMinimalOMEXMLMetadata(stacks);
    pixelSize = ome.units.quantity.Length(java.lang.Double(voxelX), ome.units.UNITS.MICROMETER);
    metadata.setPixelsPhysicalSizeX(pixelSize, 0);
    metadata.setPixelsPhysicalSizeY(pixelSize, 0);
    pixelSizeZ = ome.units.quantity.Length(java.lang.Double(voxelZ), ome.units.UNITS.MICROMETER);
    metadata.setPixelsPhysicalSizeZ(pixelSizeZ, 0);
    for c = 0 : sizeC - 1
        channel = channels(c+1);
        lc=channel.getLogicalChannel();
        cn=lc.getName.getValue();
        metadata.setChannelName(cn, 0, c);
        exw=lc.getExcitationWave().getValue();
        ExM = ome.units.quantity.Length(java.lang.Double(exw), ome.units.UNITS.NANOMETER);
        emw=lc.getEmissionWave().getValue();
        EmM = ome.units.quantity.Length(java.lang.Double(emw), ome.units.UNITS.NANOMETER);
        metadata.setChannelExcitationWavelength(ExM, 0, c);
        metadata.setChannelEmissionWavelength(ExM, 0, c);
    end

end