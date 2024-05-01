import numpy as np
from modelNumpy import Conv2D, Maxpool2d, Linear
import os
from tqdm import tqdm

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
# print(f"Conv1 Weight {conv1_weight}")

print("\n\n==================================")
#==============================================================================
# Initialize Model
conv1 = Conv2D(conv1_weight, None, stride=1, padding=1)
conv2 = Conv2D(conv2_weight, None, stride=1, padding=1)
conv3 = Conv2D(conv3_weight, None, stride=1, padding=1)

digit1 = Linear(64, 10, digit1_weight, False)
digit2 = Linear(64, 10, digit2_weight, False)
digit3 = Linear(64, 10, digit3_weight, False)

#==============================================================================
# Using single image to Testing
img_filepath = './numpy_datasets/350_988.npz'
print(f"Testing single image {img_filepath} ...")

# Loading image and golden answer from numpy npz
npz = np.load(img_filepath)
im = npz['img'] # (1, 32, 32) image
golden = npz['golden'] # answer
print(f"Image shape {im.shape}")

out = conv1(im)
out = Maxpool2d(out)

out = out // 8
# print(np.max(out))

print("=========================layear1========================")
for i in range(0, len(out)):
    for j in range(0, len(out[0])): 
        print(out[i][j])
print(np.max(out))

out = conv2(out)
out = Maxpool2d(out)

out = out // 128
# print(np.max(out))

print("=========================layear2========================")
for i in range(0, len(out)):
    for j in range(0, len(out[0])): 
        print(out[i][j])
print(np.max(out))

out = conv3(out)
out = Maxpool2d(out)

out = out // 128

print("=========================layear3========================")
for i in range(0, len(out)):
    for j in range(0, len(out[0])): 
        print(out[i][j])
print(np.max(out))

out = out.flatten()
out1 = digit1(out)
print(out1)

# out2 = digit2(out)
# out3 = digit3(out)

# # Obtain Answer
# print(f"Detection: {np.argmax(out1)}{np.argmax(out2)}{np.argmax(out3)}")
# print(f"Golden: {golden}")
# print("\n\n==================================")
#==============================================================================
# Iterate through entire folder
# folder_path = './numpy_datasets'
# successful_detected = 0
# total_num = 0

# for filename in os.listdir(folder_path):
#     if filename.endswith(('.npz')):  # Add any other file extensions as needed
#         total_num += 1

# print(f"Testing all images\nThere are {total_num} images.")

# with tqdm(total=total_num) as pbar:
#     for filename in os.listdir(folder_path):
#         if filename.endswith(('.npz')):

#             img_filepath = os.path.join(folder_path, filename)
#             npz = np.load(img_filepath)
#             im = npz['img'] # (1, 32, 32) image
#             golden = int(npz['golden']) # answer

#             out = conv1(im)
#             out = Maxpool2d(out)
#             out = out // 8

#             out = conv2(out)
#             out = Maxpool2d(out)
#             out = out // 16

#             out = conv3(out)
#             out = Maxpool2d(out)
#             out = out // 128

#             out = out.flatten()

#             out1 = digit1(out)
#             out2 = digit2(out)
#             out3 = digit3(out)

#             detection = int(f"{np.argmax(out1)}{np.argmax(out2)}{np.argmax(out3)}")

#             if detection == golden:
#                 successful_detected += 1

#             pbar.update(1)

# print(f"Accuracy: {successful_detected/total_num}")

