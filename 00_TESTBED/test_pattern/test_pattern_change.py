import os, sys, csv
import matplotlib.pyplot as plt
import numpy as np

data     = os.path.join("./ML2_KERNEL.dat")
data_n   = os.path.join("./ML2_KERNEL_n.dat")
data     = list(csv.reader(open(data)))
s7 = ["7"]
csvfile = open(data_n, 'wb')
writer  = csv.writer(csvfile) 
for i in range(0, len(data)):
    space = 0
    for j in range(0, len(data[i][0])/4):
        listt = list(data[i][0])
        if data[i][0][4*j]  == "_":
            space = 1
        if data[i][0][4*j+space]  == "f":
            listt[4*j+space]   =  "7" 
            data[i][0]   =  "".join(listt)
        if data[i][0][4*j+space]  == "e":
            listt[4*j+space]   =  "6" 
            data[i][0]   =  "".join(listt)
        if data[i][0][4*j+space]  == "d":
            listt[4*j+space]   =  "5" 
            data[i][0]   =  "".join(listt)
        if data[i][0][4*j+space]  == "c":
            listt[4*j+space]   =  "4" 
            data[i][0]   =  "".join(listt)
        if data[i][0][4*j+space]  == "b":
            listt[4*j+space]   =  "3" 
            data[i][0]   =  "".join(listt)
        if data[i][0][4*j+space] == "a":
            listt[4*j+space]   =  "2" 
            data[i][0]   =  "".join(listt)
    writer.writerow(data[i])
csvfile.close()