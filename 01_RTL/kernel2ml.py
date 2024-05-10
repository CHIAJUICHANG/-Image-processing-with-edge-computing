import os, sys, csv
import matplotlib.pyplot as plt
import numpy as np

# ----------------------open file-------------------------
data_256  = os.path.join("./SNR15dB_y_r.dat")
data_con0 = os.path.join("./CONV0_KERNEL.dat")
data_con1 = os.path.join("./CONV1_KERNEL.dat")
data_con2 = os.path.join("./CONV2_KERNEL.dat")
data_ml0  = os.path.join("./ML0_KERNEL.dat")
data_ml1  = os.path.join("./ML1_KERNEL.dat")
data_ml2  = os.path.join("./ML2_KERNEL.dat")

# ----------------------newton & convert------------------------
data_256  = list(csv.reader(open(data_256)))
data_con0 = list(csv.reader(open(data_con0)))
data_con1 = list(csv.reader(open(data_con1)))
data_con2 = list(csv.reader(open(data_con2)))

csvfile = open(data_ml0, 'wb')
writer  = csv.writer(csvfile) 
for i in range(1, len(data_con0)):
    number =0
    for j in range(0, 2):
        if data_con0[i][0][j] == '0': number += 0*(16**(1-j))
        if data_con0[i][0][j] == '1': number += 1*(16**(1-j))
        if data_con0[i][0][j] == '2': number += 2*(16**(1-j))
        if data_con0[i][0][j] == '3': number += 3*(16**(1-j))
        if data_con0[i][0][j] == '4': number += 4*(16**(1-j))
        if data_con0[i][0][j] == '5': number += 5*(16**(1-j))
        if data_con0[i][0][j] == '6': number += 6*(16**(1-j))
        if data_con0[i][0][j] == '7': number += 7*(16**(1-j))
        if data_con0[i][0][j] == '8': number += 8*(16**(1-j))
        if data_con0[i][0][j] == '9': number += 9*(16**(1-j))
        if data_con0[i][0][j] == 'a': number += 10*(16**(1-j))
        if data_con0[i][0][j] == 'b': number += 11*(16**(1-j))
        if data_con0[i][0][j] == 'c': number += 12*(16**(1-j))
        if data_con0[i][0][j] == 'd': number += 13*(16**(1-j))
        if data_con0[i][0][j] == 'e': number += 14*(16**(1-j))
        if data_con0[i][0][j] == 'f': number += 15*(16**(1-j))
    writer.writerow(data_256[number]+[' SNR15db_y_r = '+str(number+1)])
csvfile.close()

csvfile = open(data_ml1, 'wb')
writer  = csv.writer(csvfile) 
for i in range(1, len(data_con0)):
    number =0
    for j in range(0, 2):
        if data_con1[i][0][j] == '0': number += 0*(16**(1-j))
        if data_con1[i][0][j] == '1': number += 1*(16**(1-j))
        if data_con1[i][0][j] == '2': number += 2*(16**(1-j))
        if data_con1[i][0][j] == '3': number += 3*(16**(1-j))
        if data_con1[i][0][j] == '4': number += 4*(16**(1-j))
        if data_con1[i][0][j] == '5': number += 5*(16**(1-j))
        if data_con1[i][0][j] == '6': number += 6*(16**(1-j))
        if data_con1[i][0][j] == '7': number += 7*(16**(1-j))
        if data_con1[i][0][j] == '8': number += 8*(16**(1-j))
        if data_con1[i][0][j] == '9': number += 9*(16**(1-j))
        if data_con1[i][0][j] == 'a': number += 10*(16**(1-j))
        if data_con1[i][0][j] == 'b': number += 11*(16**(1-j))
        if data_con1[i][0][j] == 'c': number += 12*(16**(1-j))
        if data_con1[i][0][j] == 'd': number += 13*(16**(1-j))
        if data_con1[i][0][j] == 'e': number += 14*(16**(1-j))
        if data_con1[i][0][j] == 'f': number += 15*(16**(1-j))
    writer.writerow(data_256[number]+[' SNR15db_y_r = '+str(number+1)])
csvfile.close()

csvfile = open(data_ml2, 'wb')
writer  = csv.writer(csvfile) 
for i in range(1, len(data_con0)):
    number =0
    for j in range(0, 2):
        if data_con2[i][0][j] == '0': number += 0*(16**(1-j))
        if data_con2[i][0][j] == '1': number += 1*(16**(1-j))
        if data_con2[i][0][j] == '2': number += 2*(16**(1-j))
        if data_con2[i][0][j] == '3': number += 3*(16**(1-j))
        if data_con2[i][0][j] == '4': number += 4*(16**(1-j))
        if data_con2[i][0][j] == '5': number += 5*(16**(1-j))
        if data_con2[i][0][j] == '6': number += 6*(16**(1-j))
        if data_con2[i][0][j] == '7': number += 7*(16**(1-j))
        if data_con2[i][0][j] == '8': number += 8*(16**(1-j))
        if data_con2[i][0][j] == '9': number += 9*(16**(1-j))
        if data_con2[i][0][j] == 'a': number += 10*(16**(1-j))
        if data_con2[i][0][j] == 'b': number += 11*(16**(1-j))
        if data_con2[i][0][j] == 'c': number += 12*(16**(1-j))
        if data_con2[i][0][j] == 'd': number += 13*(16**(1-j))
        if data_con2[i][0][j] == 'e': number += 14*(16**(1-j))
        if data_con2[i][0][j] == 'f': number += 15*(16**(1-j))
    writer.writerow(data_256[number]+[' SNR15db_y_r = '+str(number+1)])
csvfile.close()