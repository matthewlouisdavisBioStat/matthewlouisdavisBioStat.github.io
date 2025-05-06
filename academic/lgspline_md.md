# lgspline: Lagrangian Multiplier Smoothing Splines

## Package Overview

lgspline is an R package that implements a novel formulation of smoothing splines through constrained optimization. This approach provides direct access to predictor-response relationships through interpretable coefficients, unlike other formulations that require post-fitting algebraic manipulation.

## Installation

```r
# Install from GitHub
devtools::install_github("matthewlouisdavisBioStat/lgspline")

# Or install from CRAN
install.packages('lgspline')
```

## Key Features

### 1. Direct Interpretation

The Lagrangian multiplier formulation provides coefficients that directly relate to the predictor-response relationship. This makes it easier to:

- Interpret the effect of predictors on the response
- Extract key insights from complex non-linear relationships
- Compare effects across different predictors

### 2. Flexible Model Specification

The package supports a wide range of model specifications:

- Multiple predictors with varying degrees of smoothness
- Interaction effects between predictors
- Linear and non-linear components
- Various distribution families through GLM-like interfaces

### 3. Penalized Likelihood

The approach uses penalized likelihood estimation to:

- Balance model fit and complexity
- Prevent overfitting
- Allow for automatic selection of smoothing parameters

### 4. Extensions Beyond Standard Smoothing Splines

The package includes several extensions to standard smoothing splines:

- Support for survival models (AFT, proportional hazards)
- Handling of censored data
- Incorporation of custom loss functions
- Integration with other statistical methods

## Mathematical Foundation

The lgspline approach reformulates the smoothing spline problem as a constrained optimization problem:

$
\min_{\beta, \gamma} \sum_{i=1}^{n} (y_i - f(x_i))^2 + \lambda \int [f''(x)]^2 dx
$

Subject to constraints that link the coefficients to the underlying function. This formulation yields coefficients that have direct interpretations in terms of the function and its derivatives.

## Basic Usage

```r
library(lgspline)

# Generate example data
set.seed(123)
x <- seq(0, 1, length.out = 100)
y <- sin(2 * pi * x) + rnorm(100, 0, 0.2)

# Fit lgspline model
fit <- lgspline(y = y, input = x, K = 10)

# Summarize results
summary(fit)

# Plot fitted curve
plot(fit)

# Predict new values
newx <- seq(0, 1, length.out = 50)
pred <- predict(fit, newx)
```

## Advanced Features

### Custom Distribution Families

The package supports various response distributions:

```r
# Poisson regression with log link
fit_poisson <- lgspline(y = count_data, 
                        input = x, 
                        family = poisson(link = "log"))

# Binomial regression with logit link
fit_binomial <- lgspline(y = binary_data, 
                         input = x, 
                         family = binomial(link = "logit"))

# Survival analysis with Weibull AFT model
fit_survival <- lgspline(y = survival_time, 
                         input = x, 
                         family = list(