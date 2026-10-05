# 8-bit Signed MAC Verification

This project contains a simple 8-bit signed Multiply-Accumulate (MAC) unit written in SystemVerilog along with a basic verification testbench.

The MAC performs the following operation on every valid clock cycle:

\[
ACC_{new} = ACC_{old} + (A \times B)
\]

Here, `A` and `B` are signed 8-bit inputs, and the accumulated result is stored in a signed 32-bit register.

The main goal of this project was to understand both the RTL implementation of a MAC unit and the basic SystemVerilog concepts used to verify it, such as classes, randomization, mailboxes, interfaces, and automated result checking.

## Project Structure

```text
asic-mac-verification/
│
├── rtl/
│   └── mac8.sv
│
├── tb/
│   └── tb_mac8.sv
│
├── constraints/
│   └── mac8.sdc
│
└── README.md
