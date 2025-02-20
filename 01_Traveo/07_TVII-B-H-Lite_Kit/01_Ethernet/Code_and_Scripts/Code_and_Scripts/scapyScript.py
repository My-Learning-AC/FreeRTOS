import scapy
from scapy.all import *
from scapy.all import Raw, sendpfast
from time import sleep

payload =  bytearray(b'a') * 1024   #Test payload
netif = 'Ethernet'
srcMAC = get_if_hwaddr("Ethernet") #Replace with the Interface name of the PC
dstMAC = 'FF:FF:FF:FF:FF:FF' #Broadcast
ethType = 0x22F0 #AVB Frame
frame = Ether(src = srcMAC, dst = dstMAC, type = ethType)/Raw(load = payload)
while True:
    sendp(frame, iface = netif)
    sleep(2)
