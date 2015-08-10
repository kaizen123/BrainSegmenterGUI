import os, sys, subprocess 
#sys.path.append('c:\\bin\\ij.jar')
from glob import glob
from ij import IJ
from ij.gui import GenericDialog

def isnan(n):
    return n != n

# function for getting paramters from dialog
def getPars(): 
    pars = []
    gd = GenericDialog('Segmentation Parameters')
    gd.addMessage('Set the parameters for nuclear segmentation if you want\nThe default ones work pretty well for nuclei\nTo detect blobs, you will need to change some')
    gd.addMessage('')
    gd.addMessage('no idea what this one does\n')
    gd.addNumericField('high_sensitivity', 0.0, 2)
    gd.addMessage('Use graph cuts algorithm for initial foregrond/background separation\n')
    gd.addNumericField('adaptive_binarization', 1.0, 2)
    gd.addMessage('Range of scales for LoG filtering. Larger values detect larger objects.\n')
    gd.addNumericField('min_LoG_scale', 9.0, 2)
    gd.addNumericField('max_LoG_scale', 14.0, 2)
    gd.addMessage('Larger values will skip small peaks in LoG output\nand should detect larger objects')
    gd.addNumericField('xy_clustering_resolution', 3.0, 2)
    gd.addNumericField('z_clustering_resolution', 2.0, 2)
    gd.addMessage('Refines the borders of initial segmentation\n')
    gd.addNumericField('finalize_segmentation', 1.0, 2)
    gd.addMessage('Sampling ratio of image stack.\nThis will depend on your optical section thickness and xy image size\n')
    gd.addNumericField('xy_to_z_sampling_ratio', 3.0, 2)
    gd.addMessage('cant remember\n')
    gd.addNumericField('use_distance_map', 1.0, 2)
    gd.addMessage('Number of pixels borders are allowed to move during refinement\n')
    gd.addNumericField('refinement_range', 6.0, 2)
    gd.addMessage('min pixel volume of object')
    gd.addNumericField('min_object_size', 500, 2)

    gd.showDialog()
    if gd.wasCanceled():
        IJ.log('\nExiting')
        exit(1)

    pars = []
    for i in range(11):
        p = gd.getNextNumber()
        pars.append(str(p))

    return pars


# image filenames must contain red, green or blue somewhere
globB = '*blue*BG.tif' 
globR = '*red*BG.tif'
globG = '*green*BG.tif'

input_xml_img = 'Input_Image.xml'
lab_im        = 'Results_Image.xml'
tab_le        = 'Results_table.txt'
proc_def_xml  = 'ProjectDef_seg.xml'
#pp = 'C:\\Farsight\\source\\bin\\exe\\release\\projproc.exe'
pp = 'C:\\Program Files (x86)\\Farsight 0.4.5\\bin\\projproc.exe'
#pnuc = 'C:\\Farsight\\source\\bin\\exe\\Debug\\compute_nuclei_features.exe'
pnuc = 'C:\\Program Files (x86)\\Farsight 0.4.5\\bin\\compute_nuclei_features.exe'

gd = GenericDialog('whoa not so fast')
gd.addMessage('Is this a batch processing job?')
gd.enableYesNoCancel()
gd.showDialog()
if gd.wasCanceled():
    IJ.log('Exiting')
    exit()

if gd.wasOKed():
    batch = True
    msg = 'Choose root folder'
else:
    batch = False
    msg = 'Choose folder containing images'

toproot = IJ.getDirectory(msg);
if not toproot:
    IJ.log('Exiting')
    exit()

dirs = []
if batch:
    dlist = os.walk(toproot).next()[1]
    for d in dlist:
        dirs.append(os.path.join(toproot,d))
else:
    dirs.append(toproot)

pars = []
for root in dirs:
    IJ.log('\nSegmenting folder: ' + root)
    fblue = glob(os.path.join(root,globB));
    fgreen = glob(os.path.join(root,globG));
    fred = glob(os.path.join(root,globR));

    # check that there is one red, green, blue image before proceeding
    if len(fblue) == 1 and len(fgreen) == 1 and len(fred) == 1:
        # if there is already a parameter file, use it
        # otherwise get params from dialog and make new one
        if not os.path.exists(os.path.join(root,proc_def_xml)):    
            if not pars:
                pars = getPars()

            IJ.log('Creating segmentation parameter file')
            f = open(os.path.join(root,proc_def_xml),'w')
            f.write('<ProjectDefinition name="foo">\n<Inputs>\n<channel number="0" name="Dapi" type="NUCLEAR" />\n<channel number="1" name="Homer" type="Homer_MARKER" />\n<channel number="2" name="Arc" type="Arc_MARKER" />\n</Inputs>\n')
            f.write('<Pipeline>\n<step name="NUCLEAR_SEGMENTATION" />\n</Pipeline>\n')
            f.write('<NuclearSegmentationParameters>\n')
            f.write('<parameter name="high_sensitivity" value="' + pars[0] + '" />\n')
            f.write('<parameter name="adaptive_binarization" value="' + pars[1] + '" />\n')
            f.write('<parameter name="LoG_size" value="30.00" />\n')
            f.write('<parameter name="min_scale" value="' + pars[2] + '" />\n')
            f.write('<parameter name="max_scale" value="' + pars[3] + '" />\n')
            f.write('<parameter name="xy_clustering_res" value="' + pars[4] + '" />\n')
            f.write('<parameter name="z_clustering_res" value="' + pars[5] + '" />\n')
            f.write('<parameter name="finalize_segmentation" value="' + pars[6] + '" />\n')
            f.write('<parameter name="sampling_ratio_XY_to_Z" value="' + pars[7] + '" />\n')
            f.write('<parameter name="Use_Distance_Map" value="' + pars[8] + '" />\n')
            f.write('<parameter name="refinement_range" value="' + pars[9] + '" />\n')
            f.write('<parameter name="min_object_size" value="' + pars[10] + '" />\n')
            f.write('</NuclearSegmentationParameters>\n</ProjectDefinition>')
            f.close()
        else:
            IJ.log('Segmentation parameter file exists, using existing parameters')
    
        # if input image file exists, use it, otherwise make a new one
        if not os.path.exists(os.path.join(root,input_xml_img)):
            IJ.log('Creating input image xml file')
            f = open(os.path.join(root,input_xml_img), 'w')
            f.write('<Image>\n<file chname="Dapi" r="0" g="0" b="255">')
            f.write(fblue[0])
            f.write('</file>\n<file chname="Homer" r="0" g="255" b="0">')
            f.write(fgreen[0])
            f.write('</file>\n<file chname="Arc" r="255" g="0" b="0">')
            f.write(fred[0])
            f.write('</file>\n</Image>')
            f.close()
        else:
            IJ.log('Input image xml file already exists, using it')

        inxml = os.path.join(root,input_xml_img)
        labxml = os.path.join(root,lab_im)
        tbl = os.path.join(root,tab_le)
        procxml = os.path.join(root,proc_def_xml)
        cmd = [pp, inxml, labxml, tbl, procxml]
        #cmd = [pp, root+input_xml_img, root+lab_im, root+proc_def_xml]
        IJ.log('\nRunning command:')
        for line in cmd:
            IJ.log(line)

        # execute the command
        # grab the stdout of the command and write it to the log window
        p = subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
        while p.poll() is None:
            line = p.stdout.readline()
            IJ.log(line)

        fblue = glob(os.path.join(root,'*blue*RAW.tif'))
        if len(fblue) != 1:
            IJ.log('Could not find raw blue image to compute nuclei features')
        else:
            nucimg = os.path.join(root,'results_image_nuc.tif')
            newtbl = os.path.join(root,'results_table_raw.txt')
            cmd = [pnuc,fblue[0],nucimg,newtbl]
            IJ.log('\nComputing nuclei features using Raw blue channel...')
            p = subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
            while p.poll() is None:
                line = p.stdout.readline()
                IJ.log(line)

            IJ.log('Done: ' + root)    

# there was not 1 each of red,green,blue images in folder
    else:
        IJ.log('\nThere should be only 3 input image files in the folder')
        IJ.log('they should contain red, green, or blue and somewhere in the name')
        IJ.log('and end with BG.tif (the output from the preprocessing)')

IJ.log('\nSegmentation Plugin Finished.')

