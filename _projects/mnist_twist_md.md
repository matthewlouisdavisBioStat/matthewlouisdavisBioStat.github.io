# MNIST with a Twist: Exploring Rotation in Latent Space

## Project Overview

This project explores whether neural networks can learn abstract concepts like "rotation" through a conditional Variational Autoencoder (VAE) trained on MNIST digit images. By building a model that can generate rotated versions of digits with controlled parameters, I investigate the boundaries between what neural networks memorize versus what they truly understand.

## Motivation

Deep generative models have shown impressive capabilities in image synthesis, but questions remain about whether they truly learn underlying concepts or simply memorize transformations. Rotation provides an ideal test case because:

1. It's a well-defined geometric transformation
2. It can be parameterized continuously (by angle)
3. It applies uniformly across different digit classes
4. The visual outcome is easy to interpret

## Methodology

### Model Architecture

I developed a conditional Variational Autoencoder with the following structure:

1. **Encoder Network**:
   - Convolutional layers to process input images
   - Fully connected layers to map to latent space
   - Outputs parameters for latent distribution (mean and variance)

2. **Latent Space**:
   - Includes digit identity (0-9)
   - Includes rotation angle as continuous variable
   - Additional latent dimensions for other variations

3. **Decoder Network**:
   - Takes latent vector plus conditioning variables
   - Series of transposed convolutions
   - Outputs reconstructed/generated image

```python
class VAE(nn.Module):
    def __init__(self, input_dim, latent_dim, num_classes,
                 units_conv1, units_conv2, units_conv3, units_conv4,
                 kernel_size1, kernel_size2,
                 units_dense1, units_dense2, units_dense3, units_dense4,
                 pool_size1, pool_size2,
                 dr_conv, dr_dense):
        super(VAE, self).__init__()
        # Encoder
        self.encoder = nn.Sequential(
            nn.Conv2d(1, units_conv1, kernel_size=kernel_size1, padding=1),
            nn.ReLU(),
            nn.Conv2d(units_conv1, units_conv1, kernel_size=kernel_size1, padding=1),
            nn.ReLU(),
            nn.MaxPool2d(pool_size1),
            nn.Conv2d(units_conv1, units_conv1, kernel_size=kernel_size2, padding=1),
            nn.ReLU(),
            nn.Conv2d(units_conv1, units_conv2, kernel_size=kernel_size2, padding=1),
            nn.ReLU(),
            nn.MaxPool2d(pool_size2),
            nn.Flatten(),
            nn.Linear(units_conv2 * 7 * 7, units_conv3),
            nn.ReLU(),
            nn.Dropout(dr_conv),
            nn.Linear(units_conv3, units_conv4),
            nn.ReLU(),
            nn.Linear(units_conv4, 2 * latent_dim)
        )
        # Decoder
        self.decoder = nn.Sequential(
            nn.Linear(latent_dim + num_classes + 1, units_dense1),
            nn.LeakyReLU(),
            nn.Linear(units_dense1, units_dense2),
            nn.LeakyReLU(),
            nn.Linear(units_dense2, units_dense3 * 7 * 7),
            nn.LeakyReLU(),
            nn.Dropout(dr_dense),
            nn.Unflatten(1, (units_dense3, 7, 7)),
            nn.ConvTranspose2d(units_dense3, units_dense3, kernel_size=kernel_size2, padding=1),
            nn.LeakyReLU(),
            nn.ConvTranspose2d(units_dense3, units_dense4, kernel_size=kernel_size2, padding=1),
            nn.LeakyReLU(),
            nn.Upsample(scale_factor=4, mode='nearest'),
            nn.ConvTranspose2d(units_dense4, units_dense4, kernel_size=kernel_size1, padding=1),
            nn.LeakyReLU(),
            nn.ConvTranspose2d(units_dense4, 1, kernel_size=kernel_size1, padding=1),
            nn.Sigmoid()
        )
    def reparameterize(self, mu, logvar):
        std = torch.exp(0.5 * logvar)
        eps = torch.randn_like(std)
        return mu + eps * std
```

### Training Process

1. **Data Preparation**:
   - Modified MNIST dataset with digits rotated at various angles
   - Preprocessing including normalization and augmentation
   - Stratified sampling to ensure balanced distribution of angles

2. **Loss Function**:
   - Reconstruction loss (binary cross-entropy)
   - KL divergence regularization
   - Auxiliary losses to encourage disentanglement

3. **Training Regime**:
   - Progressive training with curriculum learning
   - Gradually increasing complexity of rotations
   - Regularization techniques to prevent overfitting

### Evaluation Methods

I evaluated the model on several dimensions:

1. **Reconstruction Quality**:
   - Visual assessment of original vs. reconstructed images
   - Quantitative metrics (MSE, SSIM)

2. **Digit Recognition**:
   - Classification accuracy on generated images

3. **Rotation Control**:
   - Measuring angular accuracy of rotated generations
   - Testing interpolation between rotation angles

4. **Generalization**:
   - Performance on unseen rotation angles
   - Performance on out-of-distribution digits

## Results and Findings

### Successes

1. **High-Quality Generation**:
   - The model successfully generated recognizable digits
   - Reconstruction quality remained high across different digits

2. **Rotation Control**:
   - Clear rotation control within the training distribution
   - Smooth interpolation between trained rotation angles

3. **Disentanglement**:
   - Digit identity and rotation were successfully separated
   - Other style factors (thickness, slant) were captured in additional latent dimensions

### Limitations

1. **Generalization Challenges**:
   - Limited generalization to rotation angles not seen during training
   - Performance degraded significantly beyond ±30° from trained angles

2. **Mode Collapse**:
   - Some evidence of memorization rather than true understanding
   - Certain digit-rotation combinations showed stereotyped outputs

3. **Digit-Specific Behavior**:
   - Rotation worked better for some digits (1, 7) than others (8, 0)
   - Suggests the model may be learning digit-specific transformations rather than a universal concept of rotation

## Visual Results

The project includes interactive visualizations that demonstrate:

1. **Digit Generation**: Generating any digit with controlled attributes
2. **Rotation Interpolation**: Smoothly rotating a digit through various angles
3. **Latent Space Exploration**: Navigating the latent space to see how different factors interact

## Technical Implementation

The implementation uses:

- PyTorch for model development and training
- MNIST dataset with custom preprocessing
- Tensorboard for experiment tracking
- Matplotlib and interactive visualizations for results analysis

## Discussion and Insights

This project provides several insights into deep generative models:

1. **Concept Learning vs. Memorization**:
   - The model demonstrates some ability to learn the concept of rotation
   - However, evidence suggests significant memorization rather than true understanding
   - Performance on unseen angles indicates incomplete generalization

2. **Representation Learning**:
   - Rotation appears to be represented as a complex manifold rather than a simple linear dimension
   - Different digits have different "rotation manifolds"

3. **Architectural Considerations**:
   - The choice of conditioning method significantly affects disentanglement
   - Explicit rotation encoding performs better than implicit learning

## Future Directions

1. **Architectural Improvements**:
   - Exploring equivariant neural networks specifically designed for rotation
   - Testing different conditioning mechanisms

2. **Training Enhancements**:
   - More extensive data augmentation
   - Adversarial training to improve generalization

3. **Evaluation Extensions**:
   - Quantitative assessment of rotation understanding
   - Testing on more complex datasets beyond MNIST

## Conclusion

The "MNIST with a Twist" project demonstrates both the capabilities and limitations of deep generative models in learning abstract concepts. While the model successfully learns to generate rotated digits within its training distribution, its struggles with generalization suggest that it may be memorizing specific transformations rather than truly understanding rotation as an abstract concept.

This work highlights the ongoing challenges in building models that can discover and internalize abstract concepts from data, pointing to directions for future research in representation learning and generative modeling.
