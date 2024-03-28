# About Godot

Godot is a free, open-source, 2D and 3D game engine popular with indie game developers, though in the context of the MouseGoggles VR system, it is a flexible experiment design platform that is powerful enough to generate complex 3D environments, yet lightweight enough to run on a Raspberry Pi 4. It can be used to generate simple 2D images, video, and animations for visual neuroscience applications, or more commonly, it can generate 3D virtual environments and conduct complex behavioral neuroscience experiments. Godot is multi-platform engine, meaning it can run on a PC, mac, or Linux computer. And a Godot project does not need to be compiled; this means that if you want to create or edit a Godot project on one computer, you can simply copy the project folder and run it on any other computer (even one using a different operating system) without re-compiling it there.

The [official online documentation](https://docs.godotengine.org/en/3.0/) makes it [relatively] easy to get started from scratch, and there are many excellent [tutorials](https://docs.godotengine.org/en/stable/community/tutorials.html) as well. This short guide is not meant to completely replace those tutorials or make you a Godot expert, but to familiarize you with the Godot engine to the point that you're able to run VR experiments with MouseGoggles, and to make simple edits and customizations of the experiments for your own purposes.

### Installing and running the Godot game engine

On a Windows or Mac PC, download the latest Godot Engine version at [godotengine.org](godotengine.org). 

On a Raspberry Pi 4, Godot can be installed by opening the command terminal and entering each line, one at a time:

```
sudo apt update
sudo apt install flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub org.godotengine.Godot
```

After installation is complete, Godot can be run on a Raspberry Pi with the following command line:

```
flatpak run org.godotengine.Godot
```

### Project manager: importing and running projects

In the context of MouseGoggles, a project can be thought of as a collection of experiments the can be edited and run on the Raspberry Pi. When Godot is first run, a project manager window will open and list all Godot projects available on your computer. If you've downloaded a project folder from elsewhere (e.g. from a Github repository, or from another computer), this project will need to be imported by Godot before it can be edited or run. 

To import a project, start the Godot program to be brought to Godot's project manager. Click the `import` button on the right, and navigate into your new project folder. Locate the `project.godot` file inside that folder and select it to import the project. After being imported, the project can be run directly, or it can be opened into the Godot Editor where all of the project's experiment files can be read and modified. The project can also be run from inside the editor, by clicking the small green arrow on the top-right side of the editor window.

### Experiment log files

The example Godot experiments for MouseGoggles use a common format for logging experimental data. This format consists of logging the state of a number of variables for every frame. That is, each time the game loop executes, the state of those variables is logged. At the end of each experimental trial, a section of this code will save these variables in a .csv file, in the `logs` folder inside the Godot project folder. 

Each column of data in the csv file represents the values of a single variable; the header at the top of the file shows the descriptive name of these variables. Each row of the csv file shows the value of these variables for each frame.

Different experiments are designed to store different variables that are important for that experiment. For example, in experiments featuring 2D navigation, the mouse's position (x,z) and it's current orientation are important to log, whereas in experiments with only 1D navigation, only the mouse's z position needs to be logged.

### Calibrating an existing experiment

At the top of each experiment script (e.g. `linearTrackScene.gd` in Godot project 1.6), variables are set which descibe many of the experiment's parameters. Some of these parameters may need to be changed depending on your specific experimental setup. Listed below is a few parameters which are mostly likely to change, though for each experiment you run, it is wise to first look through all of the parameters to verify they make sense for your experiment.

* `trial_duration`: The duration (in s) of each trial, before a timeout is reached and the next trial starts.

* `num_reps`: The number of trial repetitions before the experiment is finished.

* `eye_pitch`: The pitch angle (in degrees) of the headset, relative to the horizon.

* `head_roll`: The roll angle (in degrees) of the headset, relative to the horizon.

* `mouse_gain`: The movement sensitivity of input signals: higher values will increase the speed virtual movement.

### Creating a new experiment

If you want to design new experiments of your own, you may choose to follow the tutorials listed at the top to create a new exxperiment from scratch. Alternatively, a simpler, faster way to create an experiment is to select an existing experiment that most closely matches the experiment you'd like to create, and copy/customize that experiment. General guidance on creating a new experiment this way and adding it to an existing project.

1. Copy the existing project, and give it a new name
   
   * Copy the "MouseVR Godot Project X.X" folder that you wish to adapt, and give the copy a unique name
   
   * Open Godot, and in the project manager window, import the new project folder you just created. The project will still have the original project name, so rename it to match the new folder you just created

2. Run the new project, copy an existing experiment, and give it a new name
   
   * From the project manager, edit the new project you just created
   
   * Selecting the experiment you wish to modify, copy both the .tscn and .gd files of that experiment. Rename these copied files to describe your new experiment.
     
     (e.g. `new_exp.tscn`; `new_exp.gd`)
   
   * Open up the .tscn file of your new experiment, and view it in the `3D` tab. In the Scene tab, identify the `spatial` node that has an attached script. This will still be the original script that you copied from, so right click the node to detach this script. Right click the node again to attach the new script you just created.

3. Edit the new experiment
   
   * Open the new .tscn file you created and view it in the `3D` tab. Edit the nodes and properties to adapt the scene to fit your desired experiment
   
   * Open the new .gd script you created and view it in the `script` tab. Modify the code to fit your desired experiment.

4. Add the new experiment to the "scene select"
   
   * Open up the sceneSelect.tscn file, and view it in the `2D` tab
   
   * In the Scene window, copy the last MarginContainer node (e.g. "MarginContainer9") and paste it in the empty space below. This will create a new margincontainer and child button node. Rename the MarginContainer node (e.g. "MarginContainer10") and drag it so that it is a child of the VBoxContainer node. This will move your new button to the top of the list of scene buttons. Since this new button will still have the same name as the button you copied, click on the new button, and in the Inspector window, rename the text to match your new experiment.
   
   * Open up the sceneSelect.gd file and view it in the `script` tab.
   
   * Copy a scene variable and rename it to match your new MarginContainer# and new experiment name 
     
     (e.g. `onready var  new_exp_button = get_node("HBoxContainer/VBoxContainer/MarginContainer10/Button")`)
   
   * in the `_ready():` function, copy a line and rename it to match your new scene variable and create a new experiment callback function.
     
     (e.g. `new_exp_button.connect("pressed",self,"_load_new_exp")`)
   
   * Copy a callback function and rename it to the function name you just created, and set it to load your new experiment.
   
   * (e.g. `func _load_new_exp():
     
         get_tree().change_scene("res://new_exp.tscn")`)
