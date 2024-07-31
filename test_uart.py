import serial
import time

ser = serial.Serial('/dev/serial0', 115200, timeout=1)
while True:
    ser.write(b'UART Test\n')
    time.sleep(1)
