# Time to Churn: Predictive Survival Analysis for Customer Retention

## Project Overview

This project applies survival analysis techniques to predict customer churn and evaluate the effectiveness of marketing interventions in a business context. Using a Weibull Accelerated Failure Time (AFT) model implemented through my lgspline R package, I developed a comprehensive system that not only predicts when customers are likely to cancel their subscriptions but also recommends optimal interventions tailored to individual customer profiles.

## Motivation

Customer churn represents a significant challenge for subscription-based businesses. Traditional classification approaches to churn prediction suffer from several limitations:

1. They ignore the temporal aspect of when churn occurs
2. They don't account for right-censored data (customers who haven't churned yet)
3. They often fail to properly evaluate the impact of interventions

By adapting survival analysis methods from medical statistics to business applications, this project offers a more nuanced approach that addresses these limitations and provides actionable insights for retention strategies.

## Methodology

### 1. Survival Modeling Framework

I implemented a Weibull Accelerated Failure Time model with several key enhancements:

- **Smoothing Splines**: Used for flexible modeling of non-linear effects
- **Penalized Likelihood**: Balanced model complexity with predictive performance
- **Interaction Effects**: Captured how interventions affect different customer segments differently
- **Regularization**: Prevented overfitting in a high-dimensional feature space

### 2. Feature Engineering

The model incorporates a rich set of features:

- **Customer Behavior**: Email engagement metrics (opens, clicks)
- **Subscription History**: Previous pauses, skips, swaps
- **Temporal Factors**: Day of year to capture seasonality
- **Intervention History**: Email campaigns and their characteristics

### 3. Robust Inference

The statistical framework provides:

- **Time-to-Event Prediction**: When a customer is likely to churn
- **Feature Importance**: Which factors most strongly influence churn
- **Causal Inference**: The effect of specific interventions on retention
- **Interaction Analysis**: How interventions perform across different customer segments

### 4. Automated Recommendation System

The project includes an automated recommendation engine that:

1. Draws from the posterior distribution of model coefficients
2. Evaluates expected profit of different intervention strategies for each customer
3. Recommends optimal interventions while maintaining statistical properties of randomized experiments
4. Continuously updates as new data becomes available

## Implementation

The core of the model is implemented using my lgspline R package, which provides a flexible framework for fitting penalized smoothing spline models. Key components include:

```r
## Load previously prepared data
load('C:/Users/defgi/Documents/Churn/predictor_response_churn.RData')

## Keep if > 30 observations only 
# Only 7 observations, remove
data$repeat_order_confirmation_gift_purchase <- NULL

# Only 12 observations, remove
data$repeat_order_confirmation_dynamic_PULLUP <- NULL

# Only 19 observations, remove
data$repeat_order_confirmation_GIFT_CITY <- NULL

# Only 25 observations, remove
data$repeat_order_confirmation_GIFT_MANOS_A <- NULL


## Unique messages we have left
unq_messages <- colnames(data)[grep('repeat_order',
                                    colnames(data))]

## Survival model
require(survival)

## Predictors
X <- data[,c(
             'n_open',
             'n_email',
             'n_click',
             'day',
             'prev_unskipped',
             'prev_skipped',
             'prev_swapped',
             'prev_paused',
              unq_messages
           )]
X <- as(X, 'matrix')
y <- (data$TIME + 1)/7
status <- data$STATUS == 1
```

### Weibull AFT Model with Smoothing Splines

The model is fit using a custom implementation that allows for flexible modeling of non-linear effects:

```r
## Fit a custom Weibull AFT spline model
fitt <- lgspline(y = y, # time std.
                 input = X,
                 just_linear_without_interactions = 8 + which(apply(X[,unq_messages],
                                                              2,
                                                              sum) <= 250),
                 exclude_interactions_for = 4, # no interactions for calendar date or sparse gift #s
                 just_linear_with_interactions = c(5:8, 8 +
                                                     which(apply(X[,unq_messages],
                                                             2,
                                                             sum) > 250)), # no quadratic/cubic for indicators
                 include_3way_interactions = FALSE,
                 include_quadratic_interactions = FALSE,
                 exclude_these_expansions = exclude_these,
                 initial_wiggle = c(1e-6, 1e-2, 10),
                 initial_flat = c(1e-2, 1),
                 unconstrained_fit_fxn = unconstrained_fit_weibull, 
                 family = list(name = "surv",
                            dist = "weibull",
                            linkfun = log,
                            linkinv = exp,
                            custom_tuning_loss = function(y, 
                                                          mu, 
                                                          order_indices, 
                                                          family, 
                                                          status){
                               log_mu <- log(mu)
                               log_y <- log(y)
                               
                               ## Initialize scale using survreg
                               init_scale <- survival::survreg(Surv(y, 
                                          status[order_indices]) ~ -1 + mu)$scale
                               
                               ## Find scale
                               scale <- optim(
                                    init_scale,
                                    fn = function(par){
                                      -loglik_weibull(log_y, 
                                                      log_mu, 
                                                      status[order_indices], 
                                                      par)
                                    },
                                    lower = init_scale/5,
                                    upper = init_scale*5,
                                    method = 'Brent'
                                  )$par
                               
                               ## -2 * log-likelihood
                               dev <- -2*(
                                 ## Log-likelihood contributions
                                 status[order_indices] * (-log(scale) +
                                                   (1/scale-1)*log_y -
                                                   log_mu/scale) -
                                   (exp((log_y - log_mu)/scale))
                               )
                               
                               return(dev)
                            }),
                    need_dispersion_for_estimation = TRUE)
```

## Results and Insights

### Model Performance

The model demonstrates strong predictive performance for time-to-churn, as shown by comparing predicted versus actual churn times:

```r
## Basic performance 
plot(fitt$ytilde[status == 0], fitt$y[status == 0],
     xlab = 'Fitted Churn (Weeks)', 
     ylab = 'Actual Churn Date or Last-Follow Up (Weeks)',
     main = 'Model Fit: Fit vs. Actual Time-to-Churn or Last Follow Up',
     col = 'blue')
points(fitt$ytilde[status == 1], fitt$y[status == 1],
     col = 'red')
legend('topright', 
       fill = c('blue','red'),
       col = c('blue','red'), 
       legend = c('Not Cancelled', 'Cancelled'))
abline(0, 1)
```

### Variable Importance

Permutation importance analysis reveals which factors most strongly influence customer churn:

```r
## Permutation importance
permute_stats <- sapply(1:ncol(X), function(i){
  mean(
    sapply(1:10, function(j){
      permuted_input <- X
      permuted_input[,i] <- sample(permuted_input[,i])
      permute_predict <- log(fitt$predict(new_input = permuted_input))
      permuted_log_likelihood <- logLik(survreg(Surv(y, status) ~ 0 + 
                                                permute_predict,
                                       scale = fitt$sigmasq_tilde))[1]
      2*(current_log_likelihood - permuted_log_likelihood)
    })
  )
})
```

### Seasonal Effects

Analysis of day-of-year effects shows interesting temporal patterns in churn behavior:

```r
## Examining relationship between time of year and churn likelihood
plot(X[,'day'], fitt$ytilde, xlab = 'Day of Year', 
     ylab = 'Predicted Time-to-Churn', main = "Time of Year vs. Churn")
abline(v = fitt$knots[,'day'])
```

### Intervention Effects

The model provides detailed insights into how different email campaigns affect customer retention, with interaction effects that vary by customer segment:

```r
## Was their any evidence that the effect of the "GIFT" treatment had some effect?
## Frequentist inference: did treatment have an effect at all?

## Maximum log-likelihood unrestricted
current_log_likelihood <-  loglik_weibull(log(fitt$y), 
                                          log(fitt$ytilde), 
                                          status, 
                                          fitt$sigmasq_tilde)
## Restricted log-likelihood (no GIFT effect)
restricted_fit <- 
        lgspline(y = y,
                 input = X,
                 /* ... abbreviated ... */
                 constraint_vectors = diag(rep(1*(grepl('repeat_order_confirmation_GIFT',
                                                        rownames(fitt$B[[1]])) & 
                                                  !grepl('repeat_order_confirmation_GIFT_',
                                                        rownames(fitt$B[[1]]))
                    ),
                  fitt$K + 1)),
                 null_constraint = t(cbind(rep(0, length(unlist(fitt$B))))))

## Likelihood ratio test
lrstat <- 2*(current_log_likelihood - restricted_log_likelihood)
pval <- (1-pchisq(lrstat, df))
```

### Customer Profiles

The model identifies typical profiles of customers most and least likely to churn:

```r
## Who is the most ideal subject, least likely to churn?
best <- fitt$find_extremum()

## Who is the least-ideal subject, most likely to churn?
worst <- fitt$find_extremum(minimize = TRUE)
```

## Automated Recommendation System

The system implements a sophisticated recommendation engine that optimizes intervention strategies for individual customers:

```r
## Auto-recommendation System
new_subject <- X[1,, drop = FALSE]
new_subject[,8+1:length(unq_messages)] <- 0

## 1. Randomly generate a posterior draw of model coefficients
new_B <- fitt$generate_posterior(
  fitt$sigmasq_tilde,
  newdat = new_subject)$post_draw_coefficients

## 2. Calculate baseline predicted profit without intervention
profit_per_week <- 5
cost_per_intervention <- 10
pred_0 <- fitt$predict(new_input = new_subject,
                       B_predict = new_B)*profit_per_week

## 3. Calculate predicted profit with intervention
preds <- c(pred_0, sapply(8 + 1:length(unq_messages), function(trt){
  newdat_trt <- new_subject
  newdat_trt[,trt] <- 1
  fitt$predict(new_input = newdat_trt,
                B_predict = new_B)*profit_per_week - 
    cost_per_intervention
}))

## 4. Identify optimal intervention
c('None', unq_messages)[which.max(preds)]
```

This approach offers several advantages:

1. It preserves many properties of randomized experiments while outperforming random assignment
2. It avoids confirmation bias by incorporating uncertainty through posterior sampling
3. It automatically adapts as new data becomes available
4. It optimizes for expected profit rather than just churn reduction

## Business Impact

The project delivers several key business benefits:

1. **Accurate Predictions**: Reliable forecasts of when specific customers are likely to churn
2. **Targeted Interventions**: Personalized retention strategies based on individual customer characteristics
3. **ROI Optimization**: Allocation of marketing resources to maximize customer lifetime value
4. **Continuous Learning**: Automatic incorporation of new data to refine predictions and recommendations
5. **Statistical Rigor**: Formal inference about intervention effects rather than just correlative patterns

## Technical Contributions

Beyond the business application, this project makes several technical contributions:

1. **Methodological Integration**: Combining survival analysis with flexible smoothing splines
2. **Bayesian Decision Framework**: Using posterior sampling for recommendation while maintaining randomization properties
3. **Interaction Modeling**: Capturing complex treatment effect heterogeneity across customer segments
4. **Open-Source Tools**: Implementation through the lgspline R package, making these methods accessible to others

## Conclusion

The "Time to Churn" project demonstrates how advanced statistical methods from medical research can be effectively adapted to business contexts. By applying survival analysis to customer churn, we gain deeper insights into not just whether customers will leave, but when they're likely to do so and how we can most effectively intervene.

The automated recommendation system moves beyond simple prediction to actionable decision-making, optimizing intervention strategies in a way that balances exploration (learning what works) with exploitation (applying what we know). This approach provides a rigorous statistical foundation for personalized customer retention strategies, ultimately leading to improved customer lifetime value and business performance.
