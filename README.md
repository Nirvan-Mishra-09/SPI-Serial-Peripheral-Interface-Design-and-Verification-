# SPI Master-Slave Design and Verification

This repository contains the SystemVerilog implementation of an SPI (Serial Peripheral Interface) master-slave communication system along with a SystemVerilog testbench for design verification.

## Table of Contents
- [Project Overview](#project-overview)
- [Design Details](#design-details)
  - [SPI Master](#spi-master)
  - [SPI Slave](#spi-slave)
  - [Top Module](#top-module)
- [Testbench](#testbench)
  - [Interface](#interface)
  - [Transaction Class](#transaction-class)
  - [Generator Class](#generator-class)
  - [Driver Class](#driver-class)
  - [Monitor Class](#monitor-class)
  - [Scoreboard Class](#scoreboard-class)
  - [Environment Class](#environment-class)
- [Simulation](#simulation)
- [How to Run](#how-to-run)
- [License](#license)

## Project Overview

This project implements an SPI master-slave communication system in Verilog. The design includes:
- **SPI Master**: Transmits data to the slave.
- **SPI Slave**: Receives data from the master.
- **Top Module**: Integrates both master and slave.

A SystemVerilog testbench is provided to verify the correct functionality of the SPI system.

## Design Details

### SPI Master

**Inputs:**
- `clk`: System clock.
- `newd`: Signal indicating new data is ready for transmission.
- `rst`: Reset signal.
- `din`: 12-bit data input to be transmitted.

**Outputs:**
- `sclk`: SPI clock signal.
- `cs`: Chip select signal.
- `mosi`: Master Out Slave In, data line.

**Functionality:**
- Generates an SPI clock (`sclk`).
- A state machine controls the transmission of data bit by bit over the `mosi` line when `newd` is high.

### SPI Slave

**Inputs:**
- `sclk`: SPI clock from the master.
- `cs`: Chip select from the master.
- `mosi`: Data input from the master.

**Outputs:**
- `dout`: 12-bit data output received from the master.
- `done`: Indicates that data reception is complete.

**Functionality:**
- Captures data on the rising edge of `sclk` and stores it in a register.
- When all bits are received, outputs the data on `dout`.

### Top Module

Integrates the `spi_master` and `spi_slave` modules, ensuring proper connection of signals between them.

## Testbench

### Interface

The `spi_if` interface defines the signals for the testbench and connects them to the DUT (Device Under Test).

### Transaction Class

The `transaction` class models the data transfer, including `newd`, `din`, and `dout` signals.

### Generator Class

The `generator` class creates random transactions and sends them to the driver.

### Driver Class

The `driver` class drives the signals of the DUT based on the transactions received from the generator.

### Monitor Class

The `monitor` class observes the outputs from the DUT and sends them to the scoreboard for comparison.

### Scoreboard Class

The `scoreboard` class checks if the data sent by the driver matches the data received by the monitor.

### Environment Class

The `environment` class ties all components together (generator, driver, monitor, and scoreboard) and controls the test execution.

## Simulation

The testbench runs a simulation with the following sequence:
1. The generator produces random input data.
2. The driver sends this data to the DUT.
3. The monitor checks the output data from the DUT.
4. The scoreboard compares the output with the expected results to verify correctness.
