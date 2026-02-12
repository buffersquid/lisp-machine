## ============================================================================
## Basys3 Rev B Constraints File (XDC)
## ============================================================================
## Usage:
## - Uncomment lines corresponding to the ports you use.
## - Replace names after `get_ports` with the actual top-level signal names.
## ============================================================================

## Clock
set_property PACKAGE_PIN W5                [get_ports CLK100MHZ]
set_property IOSTANDARD LVCMOS33           [get_ports CLK100MHZ]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports CLK100MHZ]

## ============================================================================
## Switches (SW15–SW0)
## ============================================================================
set_property PACKAGE_PIN V17               [get_ports {SWITCHES[0]}]
set_property IOSTANDARD LVCMOS33           [get_ports {SWITCHES[0]}]
set_property PACKAGE_PIN V16               [get_ports {SWITCHES[1]}]
set_property IOSTANDARD LVCMOS33           [get_ports {SWITCHES[1]}]
set_property PACKAGE_PIN W16               [get_ports {SWITCHES[2]}]
set_property IOSTANDARD LVCMOS33           [get_ports {SWITCHES[2]}]
set_property PACKAGE_PIN W17               [get_ports {SWITCHES[3]}]
set_property IOSTANDARD LVCMOS33           [get_ports {SWITCHES[3]}]
set_property PACKAGE_PIN W15               [get_ports {SWITCHES[4]}]
set_property IOSTANDARD LVCMOS33           [get_ports {SWITCHES[4]}]
set_property PACKAGE_PIN V15               [get_ports {SWITCHES[5]}]
set_property IOSTANDARD LVCMOS33           [get_ports {SWITCHES[5]}]
set_property PACKAGE_PIN W14               [get_ports {SWITCHES[6]}]
set_property IOSTANDARD LVCMOS33           [get_ports {SWITCHES[6]}]
set_property PACKAGE_PIN W13               [get_ports {SWITCHES[7]}]
set_property IOSTANDARD LVCMOS33           [get_ports {SWITCHES[7]}]
set_property PACKAGE_PIN V2                [get_ports {SWITCHES[8]}]
set_property IOSTANDARD LVCMOS33           [get_ports {SWITCHES[8]}]
set_property PACKAGE_PIN T3                [get_ports {SWITCHES[9]}]
set_property IOSTANDARD LVCMOS33           [get_ports {SWITCHES[9]}]
set_property PACKAGE_PIN T2                [get_ports {SWITCHES[10]}]
set_property IOSTANDARD LVCMOS33           [get_ports {SWITCHES[10]}]
set_property PACKAGE_PIN R3                [get_ports {SWITCHES[11]}]
set_property IOSTANDARD LVCMOS33           [get_ports {SWITCHES[11]}]
set_property PACKAGE_PIN W2                [get_ports {SWITCHES[12]}]
set_property IOSTANDARD LVCMOS33           [get_ports {SWITCHES[12]}]
set_property PACKAGE_PIN U1                [get_ports {SWITCHES[13]}]
set_property IOSTANDARD LVCMOS33           [get_ports {SWITCHES[13]}]
set_property PACKAGE_PIN T1                [get_ports {SWITCHES[14]}]
set_property IOSTANDARD LVCMOS33           [get_ports {SWITCHES[14]}]
set_property PACKAGE_PIN R2                [get_ports {SWITCHES[15]}]
set_property IOSTANDARD LVCMOS33           [get_ports {SWITCHES[15]}]

## ============================================================================
## LEDs (LD15–LD0)
## ============================================================================
set_property PACKAGE_PIN U16               [get_ports {LEDS[0]}]
set_property IOSTANDARD LVCMOS33           [get_ports {LEDS[0]}]
set_property PACKAGE_PIN E19               [get_ports {LEDS[1]}]
set_property IOSTANDARD LVCMOS33           [get_ports {LEDS[1]}]
set_property PACKAGE_PIN U19               [get_ports {LEDS[2]}]
set_property IOSTANDARD LVCMOS33           [get_ports {LEDS[2]}]
set_property PACKAGE_PIN V19               [get_ports {LEDS[3]}]
set_property IOSTANDARD LVCMOS33           [get_ports {LEDS[3]}]
set_property PACKAGE_PIN W18               [get_ports {LEDS[4]}]
set_property IOSTANDARD LVCMOS33           [get_ports {LEDS[4]}]
set_property PACKAGE_PIN U15               [get_ports {LEDS[5]}]
set_property IOSTANDARD LVCMOS33           [get_ports {LEDS[5]}]
set_property PACKAGE_PIN U14               [get_ports {LEDS[6]}]
set_property IOSTANDARD LVCMOS33           [get_ports {LEDS[6]}]
set_property PACKAGE_PIN V14               [get_ports {LEDS[7]}]
set_property IOSTANDARD LVCMOS33           [get_ports {LEDS[7]}]
set_property PACKAGE_PIN V13               [get_ports {LEDS[8]}]
set_property IOSTANDARD LVCMOS33           [get_ports {LEDS[8]}]
set_property PACKAGE_PIN V3                [get_ports {LEDS[9]}]
set_property IOSTANDARD LVCMOS33           [get_ports {LEDS[9]}]
set_property PACKAGE_PIN W3                [get_ports {LEDS[10]}]
set_property IOSTANDARD LVCMOS33           [get_ports {LEDS[10]}]
set_property PACKAGE_PIN U3                [get_ports {LEDS[11]}]
set_property IOSTANDARD LVCMOS33           [get_ports {LEDS[11]}]
set_property PACKAGE_PIN P3                [get_ports {LEDS[12]}]
set_property IOSTANDARD LVCMOS33           [get_ports {LEDS[12]}]
set_property PACKAGE_PIN N3                [get_ports {LEDS[13]}]
set_property IOSTANDARD LVCMOS33           [get_ports {LEDS[13]}]
set_property PACKAGE_PIN P1                [get_ports {LEDS[14]}]
set_property IOSTANDARD LVCMOS33           [get_ports {LEDS[14]}]
set_property PACKAGE_PIN L1                [get_ports {LEDS[15]}]
set_property IOSTANDARD LVCMOS33           [get_ports {LEDS[15]}]

## ============================================================================
## 7-Segment Display (Cathodes and Anodes)
## ============================================================================
set_property PACKAGE_PIN W7                [get_ports {CATHODES[6]}]
set_property IOSTANDARD LVCMOS33           [get_ports {CATHODES[6]}]
set_property PACKAGE_PIN W6                [get_ports {CATHODES[5]}]
set_property IOSTANDARD LVCMOS33           [get_ports {CATHODES[5]}]
set_property PACKAGE_PIN U8                [get_ports {CATHODES[4]}]
set_property IOSTANDARD LVCMOS33           [get_ports {CATHODES[4]}]
set_property PACKAGE_PIN V8                [get_ports {CATHODES[3]}]
set_property IOSTANDARD LVCMOS33           [get_ports {CATHODES[3]}]
set_property PACKAGE_PIN U5                [get_ports {CATHODES[2]}]
set_property IOSTANDARD LVCMOS33           [get_ports {CATHODES[2]}]
set_property PACKAGE_PIN V5                [get_ports {CATHODES[1]}]
set_property IOSTANDARD LVCMOS33           [get_ports {CATHODES[1]}]
set_property PACKAGE_PIN U7                [get_ports {CATHODES[0]}]
set_property IOSTANDARD LVCMOS33           [get_ports {CATHODES[0]}]
set_property PACKAGE_PIN V7                [get_ports {CATHODES[7]}]
set_property IOSTANDARD LVCMOS33           [get_ports {CATHODES[7]}]
set_property PACKAGE_PIN U2                [get_ports {ANODES[0]}]
set_property IOSTANDARD LVCMOS33           [get_ports {ANODES[0]}]
set_property PACKAGE_PIN U4                [get_ports {ANODES[1]}]
set_property IOSTANDARD LVCMOS33           [get_ports {ANODES[1]}]
set_property PACKAGE_PIN V4                [get_ports {ANODES[2]}]
set_property IOSTANDARD LVCMOS33           [get_ports {ANODES[2]}]
set_property PACKAGE_PIN W4                [get_ports {ANODES[3]}]
set_property IOSTANDARD LVCMOS33           [get_ports {ANODES[3]}]

## ============================================================================
## Buttons
## ============================================================================
# Center
set_property PACKAGE_PIN U18               [get_ports {BTN[0]}]
set_property IOSTANDARD LVCMOS33           [get_ports {BTN[0]}]
## Top
# set_property PACKAGE_PIN T18               [get_ports {BTN[1]}
# set_property IOSTANDARD LVCMOS33           [get_ports {BTN[1]}
## Left
# set_property PACKAGE_PIN W19               [get_ports {BTN[2]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {BTN[2]}]
## Right
# set_property PACKAGE_PIN T17               [get_ports {BTN[3]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {BTN[3]}]
# Bottom
set_property PACKAGE_PIN U17               [get_ports {BTN[4]}]
set_property IOSTANDARD LVCMOS33           [get_ports {BTN[4]}]

## ============================================================================
## Pmod Header JA
## ============================================================================
# set_property PACKAGE_PIN J1                [get_ports {JA[0]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JA[0]}]
# set_property PACKAGE_PIN L2                [get_ports {JA[1]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JA[1]}]
# set_property PACKAGE_PIN J2                [get_ports {JA[2]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JA[2]}]
# set_property PACKAGE_PIN G2                [get_ports {JA[3]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JA[3]}]
# set_property PACKAGE_PIN H1                [get_ports {JA[4]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JA[4]}]
# set_property PACKAGE_PIN K2                [get_ports {JA[5]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JA[5]}]
# set_property PACKAGE_PIN H2                [get_ports {JA[6]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JA[6]}]
# set_property PACKAGE_PIN G3                [get_ports {JA[7]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JA[7]}]

## ============================================================================
## Pmod Header JB
## ============================================================================
# set_property PACKAGE_PIN A14               [get_ports {JB[0]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JB[0]}]
# set_property PACKAGE_PIN A16               [get_ports {JB[1]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JB[1]}]
# set_property PACKAGE_PIN B15               [get_ports {JB[2]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JB[2]}]
# set_property PACKAGE_PIN B16               [get_ports {JB[3]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JB[3]}]
# set_property PACKAGE_PIN A15               [get_ports {JB[4]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JB[4]}]
# set_property PACKAGE_PIN A17               [get_ports {JB[5]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JB[5]}]
# set_property PACKAGE_PIN C15               [get_ports {JB[6]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JB[6]}]
# set_property PACKAGE_PIN C16               [get_ports {JB[7]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JB[7]}]

## ============================================================================
## Pmod Header JC
## ============================================================================
# set_property PACKAGE_PIN K17               [get_ports {JC[0]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JC[0]}]
# set_property PACKAGE_PIN M18               [get_ports {JC[1]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JC[1]}]
# set_property PACKAGE_PIN N17               [get_ports {JC[2]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JC[2]}]
# set_property PACKAGE_PIN P18               [get_ports {JC[3]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JC[3]}]
# set_property PACKAGE_PIN L17               [get_ports {JC[4]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JC[4]}]
# set_property PACKAGE_PIN M19               [get_ports {JC[5]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JC[5]}]
# set_property PACKAGE_PIN P17               [get_ports {JC[6]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JC[6]}]
# set_property PACKAGE_PIN R18               [get_ports {JC[7]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JC[7]}]

## ============================================================================
## Pmod Header JXADC (Analog-capable)
## ============================================================================
# set_property PACKAGE_PIN J3                [get_ports {JXADC[0]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JXADC[0]}]
# set_property PACKAGE_PIN L3                [get_ports {JXADC[1]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JXADC[1]}]
# set_property PACKAGE_PIN M2                [get_ports {JXADC[2]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JXADC[2]}]
# set_property PACKAGE_PIN N2                [get_ports {JXADC[3]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JXADC[3]}]
# set_property PACKAGE_PIN K3                [get_ports {JXADC[4]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JXADC[4]}]
# set_property PACKAGE_PIN M3                [get_ports {JXADC[5]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JXADC[5]}]
# set_property PACKAGE_PIN M1                [get_ports {JXADC[6]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JXADC[6]}]
# set_property PACKAGE_PIN N1                [get_ports {JXADC[7]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {JXADC[7]}]

## ============================================================================
## VGA Connector
## ============================================================================
# set_property PACKAGE_PIN G19               [get_ports {vgaRed[0]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {vgaRed[0]}]
# set_property PACKAGE_PIN H19               [get_ports {vgaRed[1]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {vgaRed[1]}]
# set_property PACKAGE_PIN J19               [get_ports {vgaRed[2]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {vgaRed[2]}]
# set_property PACKAGE_PIN N19               [get_ports {vgaRed[3]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {vgaRed[3]}]

# set_property PACKAGE_PIN N18               [get_ports {vgaBlue[0]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {vgaBlue[0]}]
# set_property PACKAGE_PIN L18               [get_ports {vgaBlue[1]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {vgaBlue[1]}]
# set_property PACKAGE_PIN K18               [get_ports {vgaBlue[2]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {vgaBlue[2]}]
# set_property PACKAGE_PIN J18               [get_ports {vgaBlue[3]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {vgaBlue[3]}]

# set_property PACKAGE_PIN J17               [get_ports {vgaGreen[0]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {vgaGreen[0]}]
# set_property PACKAGE_PIN H17               [get_ports {vgaGreen[1]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {vgaGreen[1]}]
# set_property PACKAGE_PIN G17               [get_ports {vgaGreen[2]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {vgaGreen[2]}]
# set_property PACKAGE_PIN D17               [get_ports {vgaGreen[3]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {vgaGreen[3]}]

# set_property PACKAGE_PIN P19               [get_ports Hsync]
# set_property IOSTANDARD LVCMOS33           [get_ports Hsync]
# set_property PACKAGE_PIN R19               [get_ports Vsync]
# set_property IOSTANDARD LVCMOS33           [get_ports Vsync]

## ============================================================================
## USB-RS232 Interface
## ============================================================================
# set_property PACKAGE_PIN B18               [get_ports RsRx]
# set_property IOSTANDARD LVCMOS33           [get_ports RsRx]
# set_property PACKAGE_PIN A18               [get_ports RsTx]
# set_property IOSTANDARD LVCMOS33           [get_ports RsTx]

## ============================================================================
## USB HID (PS/2)
## ============================================================================
# set_property PACKAGE_PIN C17               [get_ports PS2Clk]
# set_property IOSTANDARD LVCMOS33           [get_ports PS2Clk]
# set_property PULLUP true                   [get_ports PS2Clk]

# set_property PACKAGE_PIN B17               [get_ports PS2Data]
# set_property IOSTANDARD LVCMOS33           [get_ports PS2Data]
# set_property PULLUP true                   [get_ports PS2Data]

## ============================================================================
## Quad SPI Flash (use STARTUPE2 for CCLK_0 access)
## ============================================================================
# set_property PACKAGE_PIN D18               [get_ports {QspiDB[0]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {QspiDB[0]}]
# set_property PACKAGE_PIN D19               [get_ports {QspiDB[1]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {QspiDB[1]}]
# set_property PACKAGE_PIN G18               [get_ports {QspiDB[2]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {QspiDB[2]}]
# set_property PACKAGE_PIN F18               [get_ports {QspiDB[3]}]
# set_property IOSTANDARD LVCMOS33           [get_ports {QspiDB[3]}]
# set_property PACKAGE_PIN K19               [get_ports QspiCSn]
# set_property IOSTANDARD LVCMOS33           [get_ports QspiCSn]

