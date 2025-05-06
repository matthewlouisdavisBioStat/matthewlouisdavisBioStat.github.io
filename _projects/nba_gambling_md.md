# To Make an Adversary Inadmissible: A Bayesian Approach to NBA Betting

## Project Overview

In this project, I developed a statistical approach to sports betting that generated over $700 in profit during the 2022-2023 NBA regular season across hundreds of small bets. The project explores the use of historical Vegas betting performance to form prior distributions for predictive models, effectively making Vegas lines the "adversary" that my model aims to outperform consistently.

## Motivation

Sports betting markets are often considered highly efficient, making consistent profitability challenging. However, there are structural inefficiencies in these markets that can be exploited through rigorous statistical methodology. The key insight of this project is that we don't need to predict game outcomes perfectly - we only need to predict them more accurately than the betting market in specific situations.

## Methodology

### 1. Bayesian Framework

Rather than treating Vegas lines as targets to predict, I incorporate them as informative priors in a Bayesian framework. This approach acknowledges the strong predictive power of market-based lines while allowing my models to identify systematic biases or inefficiencies.

### 2. Model Stacking

I implemented an ensemble approach using model stacking, combining:
- Regularized regression models
- Bayesian hierarchical models
- Machine learning approaches (Random Forests, Gradient Boosting)

The stacking weights are determined through cross-validation on historical data, optimizing for betting return rather than purely predictive accuracy.

### 3. Features Engineering

Key predictive features include:
- Team performance metrics (offensive/defensive ratings, four factors)
- Rest and travel factors
- Player availability and lineup data
- Historical performance against Vegas lines
- Temporal effects (time of season, back-to-back games)

### 4. Decision Rules

The system doesn't bet on every game. Instead, it employs decision rules based on:
- Discrepancy between model predictions and Vegas lines
- Estimated posterior probability of winning the bet
- Kelly criterion for optimal bet sizing
- Historical performance of similar betting situations

## The Automated Pipeline

The project includes a fully automated pipeline that:

1. Pulls fresh NBA data each morning using APIs
2. Updates features and model parameters
3. Processes current Vegas betting lines
4. Generates posterior predictive distributions for upcoming games
5. Applies decision rules to identify favorable betting opportunities
6. Outputs decision spreadsheets for over/under, spread, and moneyline bets
7. Automatically emails the recommendations to specified recipients

```r
## Automatically upload data from the previous-night's games
setwd('C:/Users/defgi/Documents/AbsolutelyStackedSupplementaryFiles')
rm(list = ls())
prep_data_only <- T
update_matchups <- F
source('C:/Users/defgi/Documents/AbsolutelyStackedSupplementaryFiles/PredictAndLoadNBA_2024.R')

## Construct features from the raw data, prepare in a format suitable for model fitting
source('C:/Users/defgi/Documents/AbsolutelyStackedSupplementaryFiles/PrepDataForN