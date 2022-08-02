
# TerribleFire   [![Badge License]][License]

*Atari Accelerator Card Firmware.*

<br>

## Supported Cards

<kbd>  TF530  </kbd>  <kbd>  TF534  </kbd>

<br>
<br>

## Note

By default the **TF534** doesn't work under  `25Mhz` .

With this firmware, it can work from  `25Mhz`  up to <br>
`50Mhz` , thou it is optimized for  `33Mhz`  &  `50Mhz` .

<br>
<br>

## BOM

*Where this* ***BOM*** *differs from the schematic use the* ***BOM*** *value.*

<br>

|       Part       |       Value       |         Device          |        Package         |            Description            |
|:----------------:|:-----------------:|:-----------------------:|:----------------------:|:---------------------------------:|
| `C1 - C15`       | `10uF`            | `CAP_1206_X7R`          | `1206`                 |  Ceramic Capacitors               |
| `C16 + C17`      | `0.1uF`           | `CAP_0603_X7R`          | `0603`                 | `CAP-00810`                       |
| `C18`            | `0.1uF`           | `CAP_1206_X7R`          | `1206`                 |  Ceramic Capacitors               |
| `C19`            | `0.1uF`           | `CAP_0603_X7R`          | `0603`                 |                                   |
| `C20`            | `0.1uF`           | `CAP_0603_X7R`          | `0603`                 | `CAP-00810`                       |
| `C21 - C30`      | `0.1uF`           | `CAP_0603_X7R`          | `0603`                 |                                   |
| `C31`            | `10uF`            | `CAP_1206_X7R`          | `1206`                 |  Ceramic Capacitors               |
| `IC1`            | `MC68030RC`       | `68030`                 | `MPGA128`              | `MOTOROLA`                        |
| `IC2`            | `MC68881FN-SOC`   | `68882`                 | `PLCC68-S`             | `unknown`                         |
| `IC3`            | `LM1117-3.3`      | `V_REG_LM1117SOT223`    | `SOT223`               | Voltage Regulator `LM1117`        |
| `IC4 - IC5`      | `74LVC1G17DBV`    | `74LVC1G17DBV`          | `SOT23-5`              |  Single Schmitt-Trigger Buffer    |
| `IC6 - IC9`      | `AS6C800855ZIN`   | `AS6C800855ZIN`         | `TSOP44-II`            |                                   |
| `IC10`           | `74AC16245`       | `74AC16245`             | `SSOP48DL`             | `16-bit` \| `3-state` \|BUS Transceiver |
| `IDECONNECTOR`   | `87758-4416`      | `87758-4416`            | `87758-4416`           | `44 Pin` \| `2mm` \| Dual Row HDR |
| `INT2`           | `PINHD-1X1`       | `1X01`                  | `PIN HEADER`           |                                   |
| `JP1`            | `CLOCKSEL`        | `JUMPER-3PTH`           | `1X03`                 |                                   |
| `JP2`            | `Z2ROM`           | `JUMPER-2PTH`           | `1X02`                 |  Jumper                           |
| `JP3`            | `MMUDIS`          | `JUMPER-2PTH`           | `1X02`                 |  Jumper                           |
| `JP4`            | `ROMEN`           | `JUMPER-2PTH`           | `1X02`                 |  Jumper                           |
| `JP5`            | `CDIS`            | `JUMPER-2PTH`           | `1X02`                 |  Jumper                           |
| `JTAG`           | `JTAG`            | `HEADER-1X6`            | `0.1 header x 6`       |  Pin Header                       |
| `OSCCPU`         | `CPUMHZ`          | `OSCILLATOR`            | `OSC_7X5MM`            |  Oscillators                      |
| `PWR1`           | `EXT5V`           | `JUMPER-2PTH`           | `1X02`                 |  Jumper                           |
| `R1 + R2`        | `2K2`             | `0.05OHM-1/5W-1%(0603)` | `0603`                 | `RES-12535`                       |
| `R3`             | `47K`             | `RESISTOR1206`          | `1206`                 |  Resistors                        |
| `RN1 - RN3`      | `CAY16-222J4LF`   | `CAY16-222J4LF`         | `RESCAXE80P320X160-8N` | Res Thick Film Array `2.2KΩ`      |
| `SPIPORT`        | `SPI PORT`        | `PINHD-2X6`             | `2X06`                 |  Pin Header                       |
| `SPI_INT`        | `NONE`            | `PINHD-1X1`             | `1X01`                 |  Pin Header                       |
| `U1`             | `3.3V SPI Flash`  | `SST26VF016B`           | `SO08`                 | `32M` Serial Flash Memory         |
| `X1`             | `MC68000`         | `MC68000P`              | `DIL64`                | `68xxx` Processor                 |
| `XC9572XL(BUS)`  | `XC9572XL-VQ64`   | `XC9572XL-VQ64`         | `VQ64`                 |                                   |
| `XC95144XL(RAM)` | `XC95144XL-TQ100` | `XC95144XL-TQ100`       | `TQFP100`              |                                   |

<br>


<!----------------------------------------------------------------------------->

[Badge License]: https://img.shields.io/badge/License-GPL2-015d93.svg?style=for-the-badge&labelColor=blue

[License]: LICENSE
