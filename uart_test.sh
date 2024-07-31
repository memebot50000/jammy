import serial
import time

# Open the serial port (adjust the port name if necessary)
ser = serial.Serial('/dev/ttyAMA0', 115200, timeout=1)

while True:
    # Send data through the TXD pin
    ser.write(b'UART Test\n')
    print("Data sent: UART Test")
    time.sleep(1)
