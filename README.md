# Mean_Verilog

Arithmetic mean calculator for 2048 input values in Q1.15 fixed-point format implemented in Verilog for FPGA applications.

## Description

This project implements a hardware module that calculates the arithmetic mean of 2048 consecutive input values using Q1.15 fixed-point representation. The design is optimized for FPGA synthesis and provides efficient mean calculation for digital signal processing applications. The module uses a 28-bit internal accumulator to prevent overflow and outputs results in the same Q1.15 format as the input. It's particularly useful for moving average filters, sensor data smoothing, and noise reduction in real-time systems.

## Getting Started

### Dependencies

* Vivado 2022.2 or later (Xilinx FPGA development environment)
* Compatible FPGA target device (tested on 7-series)
* Basic knowledge of Verilog HDL and FPGA design flow

### Installing

* Download or clone the project files to your local directory
* Open Vivado and create a new RTL project
* Add the source files:
  * `mean.v` - Add as design source
  * `mean_tb.v` - Add as simulation source

### Executing program

* Open Vivado and load your project
* To run simulation:

```
# In Vivado TCL Console
launch_simulation
run all
```

* To synthesize the design:

```
# In Vivado TCL Console
synth_design -top mean
```

* For implementation and bitfile generation:

```
# After synthesis
opt_design
place_design
route_design
write_bitstream
```

## Help

Common issues and solutions:

* **Simulation not starting**: Ensure both `mean.v` and `mean_tb.v` are properly added to project
* **Synthesis errors**: Check that all port connections match the module interface
* **Timing violations**: Reduce clock frequency or add pipeline stages for higher performance

```
# To check module interface
describe mean
```

## Authors

Abdenassir El Amin - Initial work and design - [@Nassir23]

## Version History

* 0.1
    * Initial Release
    * Basic mean calculation for 2048 samples(adjustable)
    * Q1.15 fixed-point arithmetic implementation
    * Comprehensive testbench with multiple test cases

## License

This project is licensed under the MIT License - see the LICENSE.md file for details

## Acknowledgments

Inspiration, code snippets, etc.
* Xilinx Vivado Documentation
* Digital Signal Processing textbooks
* Fixed-point arithmetic references
* FPGA design best practices guides