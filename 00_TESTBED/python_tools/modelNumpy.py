import numpy as np
#============================Conv2D + Bn + ReLU======================================
class Conv2D:
    def __init__(self, weight, bias=None, stride=1, padding=0, scale=1):
        """
        Initialize the Conv2D class with weights, optional bias, stride, and padding.
        
        Args:
            weight (numpy.ndarray): The convolution filters (out_channels, in_channels, kernel_height, kernel_width).
            bias (numpy.ndarray): The bias for each filter (out_channels), optional.
            stride (int or tuple): The stride of the convolution.
            padding (int or tuple): The padding added to the input.
        """
        self.weight = weight
        self.bias = bias
        self.stride = stride if isinstance(stride, tuple) else (stride, stride)
        self.padding = padding if isinstance(padding, tuple) else (padding, padding)
        self.scale = scale

    def __call__(self, input):
        """
        Apply the convolution operation to the input using the initialized parameters.
        
        Args:
            input (numpy.ndarray): The input image (in_channels, height, width).

        Returns:
            numpy.ndarray: The result of the convolution.
        """
        return self.convolve(input)

    def convolve(self, input):
        in_channels, in_height, in_width = input.shape
        out_channels, _, kernel_height, kernel_width = self.weight.shape

        # Add padding to the input
        input_padded = np.pad(input, ((0, 0), (self.padding[0], self.padding[0]), (self.padding[1], self.padding[1])), mode='constant')

        # Calculate output dimensions
        out_height = (in_height + 2 * self.padding[0] - kernel_height) // self.stride[0] + 1
        out_width = (in_width + 2 * self.padding[1] - kernel_width) // self.stride[1] + 1

        # Create the output tensor
        output = np.zeros((out_channels, out_height, out_width))

        # Perform the convolution operation
        for channel in range(out_channels):
            for row in range(out_height):
                for col in range(out_width):
                    row_start = row * self.stride[0]
                    row_end = row_start + kernel_height
                    col_start = col * self.stride[1]
                    col_end = col_start + kernel_width

                    output[channel, row, col] = np.sum(
                        input_padded[:, row_start:row_end, col_start:col_end] * self.weight[channel, :, :, :]
                    ) + (self.bias[channel] if self.bias is not None else 0)
                    
                    # ReLu Layers
                    output[channel, row, col] = max(0, output[channel, row, col])

        return output
#===========================End of Conv2D + Bn + ReLU=================================

#============================MaxPool2D======================================
def Maxpool2d(input, pool_size=2, stride=2):
    """
    Perform max pooling on a 2D or 3D input image using NumPy.

    Args:
        input (numpy.ndarray): The input image. Can be 2D (height, width) or 3D (channels, height, width).
        pool_size (int or tuple): The size of the window to take the max over.
        stride (int or tuple): The stride of the windows.

    Returns:
        numpy.ndarray: The pooled output image.
    """
    if input.ndim == 3:
        C, H, W = input.shape
        output_shape = (C, (H - pool_size) // stride + 1, (W - pool_size) // stride + 1)
    elif input.ndim == 2:
        H, W = input.shape
        output_shape = ((H - pool_size) // stride + 1, (W - pool_size) // stride + 1)
        C = 1
        input = input.reshape((1, H, W))  # Temporarily reshape to 3D to simplify computation
    else:
        raise ValueError("Input must be a 2D or 3D array")

    # Prepare output array
    output = np.zeros(output_shape)

    # Perform max pooling
    for c in range(C):
        for h in range(output_shape[1]):
            for w in range(output_shape[2]):
                h_start = h * stride
                h_end = h_start + pool_size
                w_start = w * stride
                w_end = w_start + pool_size
                output[c, h, w] = np.max(input[c, h_start:h_end, w_start:w_end])

    if input.ndim == 2:
        output = output.reshape(output_shape[1:])  # Reshape back to 2D if input was 2D

    return output
#============================ENd of MaxPool2D======================================

#============================Linear======================================
class Linear:
    def __init__(self, in_features, out_features, weight, bias=True):
        """
        Initialize the Linear class which represents a fully connected layer.

        Args:
            in_features (int): Number of input features.
            out_features (int): Number of output features.
            bias (bool): Whether to include a bias term.
        """
        self.in_features = in_features
        self.out_features = out_features
        self.weights = weight
        self.bias = np.random.randn(out_features) if bias else None

    def __call__(self, x):
        """
        Apply the linear transformation to the input data.

        Args:
            x (numpy.ndarray): Input array of shape (N, in_features), where N is the batch size.

        Returns:
            numpy.ndarray: Output of the layer after applying the linear transformation and adding bias.
        """
        return self.forward(x)

    def forward(self, x):
        """
        Perform the forward pass of the linear layer.

        Args:
            x (numpy.ndarray): The input data.

        Returns:
            numpy.ndarray: The output data.
        """
        # Perform matrix multiplication between inputs and weights
        y = np.dot(x, self.weights.T)
        print(x)
        print(self.weights.T)
        if self.bias is not None:
            # Add bias to each output (broadcasting the bias across the batch)
            y += self.bias
        return y
#============================ENd of Linear======================================
