import numpy as np
import os

def signed_int2hex(num, bits=8):
    hex_str = ""
    if num >= 0:
        hex_str = hex(num).split('x')[1]
    else:
        hex_str = hex(2**(bits) + 1*num).split('x')[1]
    hex_str = "".join(["0"]*(int(np.ceil(bits/4))-len(hex_str))) + hex_str
    return hex_str

def signed_int2bin(num, bits=8):
    bin_str = ""
    if num >= 0:
        bin_str = bin(num).split('b')[1]
    else:
        bin_str = bin(2**(bits) + 1*num).split('b')[1]
    bin_str = "".join(["0"]*(bits-len(bin_str))) + bin_str
    return bin_str

def conv_kernal_write(conv_weight, file):
    '''hex version'''
    file.write(f"//\t\t   out_channel,\t in_channel, \tcol,\trow,\t\tint8 \n")
    for out_channel in range(conv_weight.shape[0]):
        for in_channel in range(conv_weight.shape[1]):
            #print(conv_weight[out_channel, in_channel])
            for col in range(conv_weight.shape[3]):
                for row in range(conv_weight.shape[2]):
                    file.write(f"{signed_int2hex(int(conv_weight[out_channel, in_channel, row, col]))}\t\t// ({out_channel},\t\t\t\t{in_channel},\t\t\t{col},\t\t{row}\t\t)\t{int(conv_weight[out_channel, in_channel, row, col])} \n")
#==============================================================================

# Load model ckpt from file
ckpt = np.load('./model_ckpt_numpy_8787.npz')

# Conv, BN layers
conv1_weight = ckpt['conv1']
conv2_weight = ckpt['conv2']
conv3_weight = ckpt['conv3']

# Linear layers
digit1_weight = ckpt['digit1']
digit2_weight = ckpt['digit2']
digit3_weight = ckpt['digit3']

print("Successfully loading ckpt!")

print("\n\n==================================")
#==============================================================================
# Using single image to Testing
img_filepath = './numpy_datasets/350_988.npz'
print(f"image {img_filepath} ...")

# Loading image and golden answer from numpy npz
npz = np.load(img_filepath)
im = npz['img'] # (1, 32, 32) image
golden = npz['golden'] # answer
print(f"Image shape {im.shape}")

#==============================================================================
# create folder
if not os.path.exists('./PATTERN'):
    os.makedirs('./PATTERN')
#==============================================================================
# IN_IMAGE
with open('./PATTERN/IN_IMAGE.dat', 'w') as file:
    file.write(f"//\t\t   col,\trow\n")
    for col in range(im.shape[2]):
        for row in range(im.shape[1]):
            file.write(f"0{int(im[:, row, col])}\t\t//({col},\t{row})  \n")
#==============================================================================
# GOLDEN
with open('./PATTERN/GOLDEN.dat', 'w') as file:
    for letter in str(golden):
        file.write(f"0{letter}\n")
#==============================================================================
# CONV0_KERNEL
with open('./PATTERN/CONV0_KERNEL.dat', 'w') as file:
    conv_kernal_write(conv1_weight, file)
#==============================================================================
# CONV1_KERNEL
with open('./PATTERN/CONV1_KERNEL.dat', 'w') as file:
    conv_kernal_write(conv2_weight, file)
#==============================================================================
# CONV2_KERNEL
with open('./PATTERN/CONV2_KERNEL.dat', 'w') as file:
    conv_kernal_write(conv3_weight, file)
#==============================================================================
# LINEAR_WEIGHT
def linear_write(digit_weight, file, digi_no):
    #print(digit_weight)
    for col in range(digit_weight.shape[0]):
        for row in range(digit_weight.shape[1]):
            file.write(f"{signed_int2hex(digit_weight[col, row])}\t\t//{digi_no},\t\t{col},\t\t\t{row}\n")

with open('./PATTERN/LINEAR_WEIGHT.dat', 'w') as file:
    file.write(f"//\t\tlinear,\t\trow,\t\tcol \n")
    linear_write(digit1_weight, file, 1)
    linear_write(digit2_weight, file, 2)
    linear_write(digit3_weight, file, 3)
    
