SET connectport=22
SET vps-hostname=192.168.2.8
SET _putty=E:\windows\_downloads\35.putty\putty

%_putty% -ssh -P %connectport% -pw raspberry pi@%vps-hostname%
