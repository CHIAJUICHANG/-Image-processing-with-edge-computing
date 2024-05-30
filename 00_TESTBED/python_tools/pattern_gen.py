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
# create folder
if not os.path.exists('./PATTERN'):
    os.makedirs('./PATTERN')
if not os.path.exists('./PATTERN/image'):
    os.makedirs('./PATTERN/image') 
if not os.path.exists('./PATTERN/golden'):
    os.makedirs('./PATTERN/golden') 
if not os.path.exists('./PATTERN/linear_out'):
    os.makedirs('./PATTERN/linear_out') 
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
    
#==============================================================================
from modelNumpy import Conv2D, Maxpool2d, Linear
#==============================================================================
# Initialize Model
conv1 = Conv2D(conv1_weight, None, stride=1, padding=1)
conv2 = Conv2D(conv2_weight, None, stride=1, padding=1)
conv3 = Conv2D(conv3_weight, None, stride=1, padding=1)

digit1 = Linear(64, 10, digit1_weight, False)
digit2 = Linear(64, 10, digit2_weight, False)
digit3 = Linear(64, 10, digit3_weight, False)
#==============================================================================

# IN_IMAGE
idx = 0
successful_detected = 0

max_linear_over_datasets = -1000
min_linear_over_datasets = 1000

for filename in os.listdir('./numpy_datasets'):
    if '.npz' not in filename:
        continue
    img_filepath = f'./numpy_datasets/{filename}'
    npz = np.load(img_filepath)
    im = npz['img'] # (1, 32, 32) image
    golden = int(npz['golden'])
    with open(f'./PATTERN/image/p{idx}.dat', 'w') as file:
        file.write(f"//\t\t   col,\trow\n")
        for col in range(im.shape[2]):
            for row in range(im.shape[1]):
                file.write(f"0{int(im[:, row, col])}\t\t//({col},\t{row})  \n")

    # calculate python detection
    out = conv1(im)
    out = Maxpool2d(out)
    out = out // 8

    out = conv2(out)
    out = Maxpool2d(out)
    out = out // 128

    out = conv3(out)
    out = Maxpool2d(out)
    out = out // 128

    out = out.flatten()

    out1 = digit1(out)
    out2 = digit2(out)
    out3 = digit3(out)

    if np.max([np.max(out1), np.max(out2), np.max(out3)]) > max_linear_over_datasets:
        max_linear_over_datasets = np.max([np.max(out1), np.max(out2), np.max(out3)])
    
    if np.min([np.min(out1), np.min(out2), np.min(out3)]) < min_linear_over_datasets:
        min_linear_over_datasets = np.min([np.min(out1), np.min(out2), np.min(out3)])

    detection = int(f"{np.argmax(out1)}{np.argmax(out2)}{np.argmax(out3)}")
    if detection == golden:
        successful_detected += 1
    
    detection = [np.argmax(out1), np.argmax(out2), np.argmax(out3)]

    # GOLDEN
    with open(f'./PATTERN/golden/p{idx}.dat', 'w') as file:
        for letter in detection:
            file.write(f"0{letter}\n")

    # Linear out
    with open(f'./PATTERN/linear_out/p{idx}.dat', 'w') as file:
        file.write(f'Original: {golden}\n')
        file.write(f'#num0: {np.argmax(out1)}\n')
        for num in out1:
            file.write(f"{signed_int2hex(int(num), 16)} ")
        file.write('\n')
        file.write(f'#num1: {np.argmax(out2)}\n')
        for num in out2:
            file.write(f"{signed_int2hex(int(num), 16)} ")
        file.write('\n')
        file.write(f'#num2: {np.argmax(out3)}\n')
        for num in out3:
            file.write(f"{signed_int2hex(int(num), 16)} ")
        file.write('\n')

    idx += 1
    if idx == 10000:
        break

print(f"Acc: {successful_detected/idx}")
print(f"max of linear over entire datasets: {max_linear_over_datasets}, {signed_int2hex(int(max_linear_over_datasets), 16)} ")
print(f"min of linear over entire datasets: {min_linear_over_datasets}, {signed_int2hex(int(min_linear_over_datasets), 16)} ")