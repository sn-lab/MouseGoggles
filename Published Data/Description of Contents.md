# Description of Contents

This folder contains datasets and code used in the intial MouseGoggles publication. Raw data, pre-processed data, and analyzed data is included in the "data" folder when possible; large raw data files unsuitable for github are hosted by [FigShare](https://figshare.com/articles/dataset/Raw_image_files/24039021).
For each dataset, Matlab and/or python code used to process and plot data are included. The sections below detail the contents of each dataset folder and how the publication data can be reproduced.


### 2P Imaging
This folder contains two-photon imaging data, experimental protocol metadata, and processing/plotting code for 3 mouse imaging sessions. Raw Imaging data files too large for github are hosted by Figshare at the link above. Also on Figshare are the motion corrected calcium imaging data files associated with these raw data files, located here: https://figshare.com/account/items/24039042
To reproduce the published results from preprocessed data files included in this folder, open the `monoDisplay_VR2_analysis.m` file in Matlab and run section 3. 
Alternatively, To reproduce the data from raw imaging files, download the files from figshare and put each of the 3 raw imaging files into the associated mouse folder (e.g., "rfm0d0t0_mouse1.tif" into the "mouse1" folder). Next open the `monoDisplay_VR2_analysis.m` file in Matlab and run sections 1 and 2 for each mouse folder individually to preprocess these raw imaging files. Section 1 extracts the TTL synchronization signal from the imaging data (indices of the imaging frames at the start of every experimental stimulus set will be contained in the `starts.mat` file) and creates motion-corrected calcium image files. Following the instructions in section 2, these calcium imaging files must next be loaded into suite2p for automatic ROI segmentation and neuron activity extraction, which will generate a "suite2p" folder of data for each imaging file. All neuron activity data needed for analysis and plotting will be contained in`>suite2p>plane0>Fall.mat`. After this has been performed for each mouse dataset, section 3 of `monoDisplay_VR2_analysis.m` can be run to analyze and plot the data. Note however the example neuron plots in section 3 may not work well if the suite2p dataset has changed; if that is the case, new example neurons should be found through manual inspection of the data.
For more details about experimental protocol or to reproduce the experiment yourself, `monoDisplay_VR2_presentation.m` is the monocular display control script which generated and presented the stimulus sets used in this dataset.

### Looming
This folder contains behavioral scoring details and data from 2 independent semi-blind scorers to find mouse startle reactions to looming visual stimuli. In the "Reaction Log" .xlsx files, scorers were given instructions as to how to score video clips of mice reacting to looming stimuli from either a projector VR system or the MouseGoggles VR system. These video clips are stored on Figshare at the link above, in the "loom_videos.zip" file. To reproduce the published results from this dataset, run the `analyze_manual_loom.m` script in Matlab.

### Linear track
This folder contains all logged data from the 5-day continuous loop linear track place learning protocol, performed with 10 mice over 2 datasets. Each dataset contains logged data for 40 track traversals each day over 5 days, from 5 mice. Due to some occasional Raspberry Pi/Godot glitches, some experiments had to be restarted resulting in >40 traversals for some mice on some days; these extra traversals are unused in this analysis. In all logged data files, data is stored in csv format, where each line stored data for a single frame of the game loop, and the columns each store a unique datatype according to the following structure:
column 1: spherical treadmill yaw motion
column 2: spherical treadmill pitch motion
column 3: spherical treadmill roll motion
column 4: mouse x (horizontal) position (locked at 0.5 in this experiment)
column 5: mouse z (position along track) position
column 6: mouse head angle (locked at 180 degrees in this experiment)
column 7: water reward given signal
column 8: lick sensor detection signal
column 9: timestamp (in ms, from program start)
To reproduce the published results from this data, run the `analyze_godot_lineartrackV5B_allsets.m` script in Matlab. To reproduce or visualize this experiment, open the Godot program and select the 'linear track' scene, defined by the game program file `linearTrackScene.gd` in the Godot project folder.


### CA1 Ephys
This folder contains code for processing and plotting electrophysiological recording during continuous loop linear track traversal. The data used by this code is stored according to [CellExplorer data format standards](https://cellexplorer.org/datastructure/data-structure-and-format/) and hosted by Figshare at the link above.
To reproduce the published results from this dataset, download the VR_ephys_8sessions.zip file and unzip it into the CA1 Ephys folder. To plot the processed data, the `plot_vr_place_cells.ipynb` notebook calls the main processing script located in `vr_place_cells.py`. For Windows 10 users, the full environment to run this notebook/script can be installed by creating a conda environment using the environment.yml.


### software dependencies
	* Matlab 2022b
	* Python 2.8.8
	* suite2p (suite2p.org)
	* https://github.com/misaacson01/NoRMCorre
	* https://github.com/lolaBerkowitz/SNLab_ephys
	* https://github.com/nelpy/nelpy
	* https://github.com/ryanharvey1/neuro_py
	* https://github.com/ryanharvey1/ripple_heterogeneity
