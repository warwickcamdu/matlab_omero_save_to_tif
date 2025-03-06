# matlab_omero_save_to_tif
Laura Cooper, camdu@warwick.ac.uk

1. Download the Matlab OMERO toolbox from: https://www.openmicroscopy.org/omero/downloads/ and the Matlab Bioformats toolbox from https://www.openmicroscopy.org/bio-formats/downloads/
2. Unzip the toolboxes and add them to your Matlab path
3. Download the matlab_omero_save_to_tif.m script, open for editing (you can also add to the matlab path at this stage to skip the warning later)
4. Create a username and password variable. Matlab saves the password in plain text so be careful and don't save the workspace. Then clc to clear the command window.
5. List the IDs for the images to be downloaded and saved as ome.tifs in the variable ```imageIDs``` on line 8 of matlab_omero_save_to_tif.m
6. Run the script

Resulting ome.tifs will be saved in the current working directory. To change this modify the output_name variable on line 16 by prepending the current value with the desired path
