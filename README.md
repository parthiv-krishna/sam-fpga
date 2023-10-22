# sam-fpga
Infrastructure to implement Sparse Abstract Machine dataflow graphs on Xilinx FPGAs

## Vivado (Hardware) Project

### Building the project
To build the project, first enter the `hw` directory
```bash
cd hw
```

Then, launch Vivado (2023.1)
```
vivado &
```

Within Vivado, at the top, go to `Window -> Tcl Console`. Within the Tcl console, run
```tcl
source build.tcl
```

This will generate the Vivado project inside the subdirectory `sam-fpga`.

### Rebuilding the project (e.g. after new RTL files are added or the block diagram is changed)
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
