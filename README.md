## Features
- **LED patterns:** displays three patterns on a 3x3 LED matrix
- **Tilt control:** move an LED around the matrix by tilting an analog accelerometer (MCP3008 ADC), with auto-calibration
- **LSM303D accelerometer:** reads X/Y/Z acceleration over I2C
- **Temperature:** reads the LSM303D's built-in temperature sensor

## Hardware
Raspberry Pi, 3x3 LED matrix, MCP23017 I/O expander, MCP3008 ADC,
analog 3-axis accelerometer, LSM303D breakout board

## Running
Install [Racket](https://racket-lang.org/) on the Pi, then:

    racket led-matrix/patterns.rkt

The code was fully written in Scheme (DrRacket).
