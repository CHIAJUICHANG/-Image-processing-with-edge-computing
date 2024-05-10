import os, sys, csv
import matplotlib.pyplot as plt
import numpy as np

# ----------------------open file-------------------------
data_h = os.path.join("./SNR15dB_hb.dat")
data_y = os.path.join("./SNR15dB_pat_y_hat.dat")
data_r = os.path.join("./SNR15dB_pat_r.dat")
data_c = os.path.join("./SNR15db_y_r.dat")

# ----------------------newton & convert------------------------
data_h   = list(csv.reader(open(data_h)))
data_y   = list(csv.reader(open(data_y)))
data_r   = list(csv.reader(open(data_r)))
count  = 0
number = 0
csvfile = open(data_c, 'wb')
writer  = csv.writer(csvfile) 
for i in range(0, 256):
    clr = 0
    for j in range(0, len(data_h)) :
        if (data_h[j] == ['1']):    
            number += 2**(7-count)
        count = count+1
        if count == 8:
            count = 0
            if number == i:
                packet = '5'
                row = j//8+1
                if (j > 7999):
                    row = (j-8000)//8
                    packet = '6'
                writer.writerow([data_y[j//8][0]+'_'+data_r[j//8][0]+'    # packet = '+packet+', row = '+str(row)])
                clr = 1
                break
            number = 0
        if j == len(data_h)-1 and clr == 0:
            print(i)
csvfile.close()

# # ----------------------newton & convert------------------------
# plt.figure (1)
# plt.plot   (timee, freq1, label='case1')
# plt.plot   (timee, freq2, label='case2')
# # plt.plot   (timee, freq3, label='case3')
# # plt.plot   (timee, f5997, label='frequency=59.97',color='red')
# # plt.plot   (timee, gain159, label='constant gain')
# plt.legend ()
# plt.xlim   ([0,timee[-1]])
# plt.xlabel ('Time(s)')
# # plt.ylabel ('Frequency(Hz)')
# # plt.ylabel ('Power(MW)')
# # plt.ylabel ('ITAE')
# plt.ylabel ('Gain')
# plt.show   ()