# sam-fpga
Infrastructure to implement Sparse Abstract Machine dataflow graphs on Xilinx FPGAs

## Vivado (Hardware) Project

### Building the project
To build the project, first enter the `hw` directory
```bash
cd hw
```

Then, launch Vivado (2023.1)
```bash
vivado &
```

Within Vivado, at the top, go to `Window -> Tcl Console`. Within the Tcl console, run
```tcl
source build.tcl
```

This will generate the Vivado project inside the subdirectory `sam-fpga`.

With the project now open, click on `Generate Bitstream` on the left side menu. This runs various steps to generate the FPGA programming bitstream. 

Once this completes, go to `File -> Export -> Export Hardware`. Make sure to select the option to include bitstream. Export the hardware to some known location (recommended: call it `sam_fpga.xsa` and save it just inside the `hw` directory).

### Rebuilding the project
You will want to do this after new RTL files are added or the block diagram is changed. If you're just editing existing RTL files, you won't need to rebuild the project; you'll just re-generate the bitstream and re-export the hardware using the existing project.

Since the `build.tcl` script easily builds the project repeatably, it's easiest to just rebuild.
```bash
cd hw
rm -r sam-fpga
```
Then follow the `Building the project` steps above.

### Adding new files to the project
Suppose you create a new Verilog or SystemVerilog module file `module.v/sv`, or a new testbench file `module_testbench.v/sv` . First, make sure that this file is placed within `hw/hdl` for modules, or `hw/testbenches` for testbenches. 

Then, you will need to edit the `build.tcl` script. All locations where you nede to add files have a comment of the form 

```
# ADD FILES HERE: <category>
```

`<category>` will be either `ALL`, `MODULES`, or `TESTBENCHES`.

If you're making a new module file, add it under any comment with `ALL` or `MODULES`. If you're making a new testbench file, add it under any comment with `ALL` or `TESTBENCHES`. Match the format of the other lines, it should be pretty self-explanatory.

### Changing the top-level (default) simulation
Look for the comment `# CHANGE TOP TESTBENCH HERE`. On the line below, you'll see that it's of the form

```tcl
set_property -name "top" -value "module_tb" -objects $obj
```

Replace the current `module_tb` with the name of the testbench module you want to run as the default simulation. Note that you can set this up manually in Vivado too by right-clicking the testbench you want and setting it as top. This will just change the default when you rebuild the project.



## Vitis (Software) Project

### Creating the project
First, enter the `sw` directory
```bash
cd sw
```

Then, launch Vitis
```
vitis &
```

Now, select the workspace as follows
```
/path/to/sam-fpga/sw/ws
```

Once Vitis opens, follow the steps below:
- Click `Create Application Project`
- On the Welcome page
    - Press `Next`
- On the Platform page
    - Select `Create a new platform from hardware (XSA)`
    - Click on `Browse...` and navigate to the XSA file you exported from Vivado (probably in `/path/to/sam-fpga/hw`)
    - Select the XSA file you exported
    - Ensure that `Generate boot components` is selected
    - Platform name: can be anything (e.g. `sam_fpga`)
    - Click `Next`
- On the Application Project Details page
    - Click `Create new...` on the left
    - Enter project name at the top: `sam`
    - The System project name should auto-populate as `sam_system`
    - The `sam` application should automatically be mapped to `ps7_cortexa9_0`
    - Click `Next`
- On the Domain page
    - Click `Create new...` on the left
    - Leave the details as their defaults
        - Name/Display Name: `standalone_ps7_cortexa9_0`
        - Operating System: `standalone`
        - Processor: `ps7_cortexa9_0`
        - Architecture: `32 bit`
    - Click `Next`
- On the Templates page
    - Select `Empty Application (C++)`
    - Click `Finish`

The new project will be generated at `sw/ws/sam`. After the project is created, execute the command below in the terminal (from the `sam-fpga` directory) to copy the files into the Vitis project:

```bash
cp sw/src/* sw/ws/sam/src
```

You should now see the files show up in Vitis under the `src` folder in the `sam` application in the `sam_system` system. 

### Editing files

You can edit the files in Vitis or any other editor. Unfortunately, right now, the files in Vitis (at `sw/ws/sam/src`) will be different than the files in the Git repo (at `sw/src`). So in order to get things checked in to Git, you'll have to copy them back to `sw.src`. You can use the command below:

```bash
cp sw/ws/sam/src/*.[ch]* sw/src/*
```

### Building and running the project

To build the project, you can use the keyboard shortcut `Ctrl+B`. Alternatively, you can right-click on the `sam_system` at the `Assistant` on the bottom left of Vitis and then click `Build` in the menu that pops up. 

To run the project on the Zedboard, you'll first have to connect two micro USB cables to your computer. One will connect to the `PROG` micro USB port and the other to the `UART` micro USB port. Open up a Serial connection to the ZedBoard at 115200 baud, e.g. via PuTTY (Windows) or Minicom:
```bash
minicom -b 115200 -D /dev/ttyACM0
```

You may need to use Device Manager (Windows) to find the appropriate COM port, or `ls /dev/tty*` to find the appropriate port (probably `/dev/ttyACM#` or `/dev/ttyUSB#`). 

Right-click on the `sam_system` at the `Assistant` on the bottom left of Vitis. In the menu that pops up, click on `Run`->`Launch Hardware`. 
