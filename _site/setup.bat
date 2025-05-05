#!/bin/bash
# Setup script for a statistics research website using Jekyll

# Create project directory
mkdir -p statistics-website
cd statistics-website

# Check if Jekyll is installed
if ! command -v jekyll &> /dev/null; then
    echo "Jekyll not found. Installing Jekyll..."
    
    # Check if Ruby is installed
    if ! command -v ruby &> /dev/null; then
        echo "Ruby not found. Please install Ruby first:"
        echo "  For Ubuntu/Debian: sudo apt-get install ruby-full build-essential"
        echo "  For macOS: brew install ruby"
        echo "  For Windows: Use RubyInstaller from https://rubyinstaller.org/"
        exit 1
    fi
    
    # Install Jekyll and Bundler
    gem install jekyll bundler
fi

# Create a new Jekyll site
echo "Creating new Jekyll site..."
jekyll new --skip-bundle .

# Update Gemfile (uncomment GitHub Pages gem and comment out jekyll gem)
sed -i.bak 's/^gem "jekyll"/# gem "jekyll"/' Gemfile
sed -i.bak 's/^# gem "github-pages"/gem "github-pages", group: :jekyll_plugins/' Gemfile
rm Gemfile.bak

# Create project structure
mkdir -p _projects _publications _data assets/images

# Create project data files
cat > _data/navigation.yml << 'EOL'
- name: Home
  link: /
- name: Research
  link: /research/
- name: Projects
  link: /projects/
- name: Publications
  link: /publications/
- name: Blog
  link: /blog/
- name: Contact
  link: /contact/
EOL

# Create basic configuration file
cat > _config.yml << 'EOL'
title: Matthew L. Davis | Biostatistics Research
email: matthew-l-davis@uiowa.edu
description: >-
  Personal website of Matthew L. Davis, featuring research in biostatistics,
  R package development, and statistical methods for microbiome data analysis.
baseurl: ""
url: ""

# Social profiles
github_username: matthewlouisdavisBioStat
twitter_username: 
linkedin_username: 

# Build settings
markdown: kramdown
theme: minima
plugins:
  - jekyll-feed
  - jekyll-seo-tag

# Collections
collections:
  projects:
    output: true
  publications:
    output: true

# Defaults
defaults:
  - scope:
      path: ""
      type: "posts"
    values:
      layout: "post"
  - scope:
      path: ""
      type: "projects"
    values:
      layout: "project"
  - scope:
      path: ""
      type: "publications"
    values:
      layout: "publication"
  - scope:
      path: ""
    values:
      layout: "default"
EOL

# Create project pages
cat > _projects/lgspline.md << 'EOL'
---
title: "lgspline: Lagrangian Multiplier Smoothing Splines"
description: "An R package implementing a novel formulation of smoothing splines through constrained optimization"
github: https://github.com/matthewlouisdavisBioStat/lgspline
website: 
thumbnail: /assets/images/lgspline_thumbnail.png
featured: true
order: 1
---

## Overview

The `lgspline` R package implements Lagrangian multiplier smoothing splines, which reformulate smoothing splines through constrained optimization. This approach provides direct access to predictor-response relationships through interpretable coefficients, unlike other formulations that require post-fitting algebraic manipulation.

## Installation

```r
# Install from GitHub
devtools::install_github("matthewlouisdavisBioStat/lgspline")

# Or install from CRAN
install.packages('lgspline')
```

## Key Features

- Direct interpretation of predictor-response relationships
- Reformulation of smoothing splines using constrained optimization
- User-friendly interface for fitting complex models
- Comprehensive visualization tools

## Example Usage

```r
library(lgspline)

# Generate some example data
set.seed(123)
x <- seq(0, 10, length.out = 100)
y <- sin(x) + rnorm(100, 0, 0.2)
data <- data.frame(x = x, y = y)

# Fit a smoothing spline with lgspline
fit <- lgspline(y ~ x, data = data)

# Plot the results
plot(fit)

# Make predictions
new_data <- data.frame(x = seq(0, 10, length.out = 200))
predictions <- predict(fit, newdata = new_data)
```

## Citation

If you use this package in your research, please cite:

```
Davis, M. (2025). Lagrangian Multiplier Smoothing Splines.
https://github.com/matthewlouisdavisBioStat/lgspline/
```
EOL

cat > _projects/rank-normalization.md << 'EOL'
---
title: "Rank Normalization for Microbiome Data Analysis"
description: "A framework for using rank normalization with a t-test for microbiome differential abundance analysis"
github: https://github.com/matthewlouisdavisBioStat/Rank-Normalization-Empowers-a-T-Test
paper: https://academic.oup.com/bib/article/22/5/bbab059/6210069
thumbnail: /assets/images/rank_normalization_thumbnail.png
featured: true
order: 2
---

## Overview

This project provides a framework for using rank normalization with a t-test for microbiome differential abundance analysis. This method offers strong control over the false discovery rate while maintaining good statistical power, especially with larger sample sizes.

## Key Findings

- Rank normalization with a t-test offers strong control over false discovery rate
- At sample sizes greater than 50 per treatment group, this approach outperforms many commonly used methods
- The method yields reproducible results in agreement with published findings

## Example Implementation

```r
# Basic implementation of rank normalization with t-test
rankNormTTest <- function(data, group) {
  # Replace counts with intrasample ranks
  ranked_data <- apply(data, 2, rank)
  
  # Perform t-test on each feature
  results <- apply(ranked_data, 1, function(x) {
    t.test(x ~ group)$p.value
  })
  
  return(results)
}
```

## Publication

This research is published in Briefings in Bioinformatics:

Davis, M. L., Huang, Y., & Wang, K. (2021). Rank normalization empowers a t-test for microbiome differential abundance analysis while controlling for false discoveries. Briefings in Bioinformatics, 22(5), bbab059. [DOI: 10.1093/bib/bbab059](https://doi.org/10.1093/bib/bbab059)
EOL

# Create publications
cat > _publications/rank-normalization-paper.md << 'EOL'
---
title: "Rank normalization empowers a t-test for microbiome differential abundance analysis while controlling for false discoveries"
authors: "Matthew L. Davis, Yuan Huang, Kai Wang"
journal: "Briefings in Bioinformatics"
volume: "22"
issue: "5"
date: 2021-09-01
doi: "10.1093/bib/bbab059"
link: "https://academic.oup.com/bib/article/22/5/bbab059/6210069"
featured: true
---

## Abstract

A major task in the analysis of microbiome data is to identify microbes associated with differing biological conditions. Before conducting analysis, raw data must first be adjusted so that counts from different samples are comparable. We propose to use rank normalization as an alternative to the estimation of normalization factors and examine its performance when paired with a two-sample t-test.

On a rigorous 3rd-party benchmarking simulation, it is shown to offer strong control over the false discovery rate, and at sample sizes greater than 50 per treatment group, to offer an improvement in performance over commonly used normalization factors paired with t-tests, Wilcoxon rank-sum tests and methodologies implemented by R packages. On two real datasets, it yielded valid and reproducible results that were strongly in agreement with the original findings and the existing literature, further demonstrating its robustness and future potential.

## Resources

The data underlying this article are available online along with R code and supplementary materials at [GitHub](https://github.com/matthewlouisdavisBioStat/Rank-Normalization-Empowers-a-T-Test).
EOL

cat > _publications/lgspline-paper.md << 'EOL'
---
title: "Lagrangian Multiplier Smoothing Splines"
authors: "Matthew L. Davis"
journal: ""
date: 2025-01-01
link: "https://github.com/matthewlouisdavisBioStat/lgspline"
featured: true
---

## Abstract

This work introduces a reformulation of smoothing splines through constrained optimization, providing direct access to predictor-response relationships through interpretable coefficients. The implementation is available as an R package, offering a user-friendly interface for researchers working with complex data.

## Resources

The R package is available on [GitHub](https://github.com/matthewlouisdavisBioStat/lgspline).
EOL

# Create blog posts
mkdir -p _posts
cat > _posts/2025-05-01-understanding-rank-normalization.md << 'EOL'
---
layout: post
title: "Understanding Rank Normalization for Microbiome Data"
date: 2025-05-01
categories: [Microbiome, Statistics]
---

Microbiome data present unique analytical challenges due to their high dimensionality, sparsity, and compositional nature. In this post, I discuss why rank normalization offers an elegant solution to many of these challenges when paired with a t-test for differential abundance analysis.

## The Challenge of Microbiome Data

Microbiome data are typically presented as counts of microbial taxa across multiple samples. These data have several characteristics that make traditional statistical approaches challenging:

1. **Compositionality**: The total number of sequencing reads varies between samples, making raw counts non-comparable.
2. **Sparsity**: Many taxa have zero counts in many samples.
3. **Overdispersion**: The variance of counts is typically much larger than the mean.

## Traditional Normalization Approaches

Researchers often use normalization factors to make counts comparable across samples. Common approaches include:

- Total Sum Scaling (TSS)
- Relative Log Expression (RLE)
- Trimmed Mean of M-values (TMM)

However, these methods have limitations, particularly when dealing with highly sparse data or when the underlying assumptions are violated.

## Why Rank Normalization Works

Rank normalization is a nonparametric alternative that replaces counts with their intrasample rank. This approach has several advantages:

1. **Robustness to outliers**: Extreme values do not disproportionately influence the analysis.
2. **No parametric assumptions**: The approach does not assume any particular distribution for the data.
3. **Handles zeros gracefully**: Zeros are assigned ranks based on their frequency in each sample.

When paired with a t-test, rank normalization provides strong control over the false discovery rate while maintaining good statistical power, especially with larger sample sizes.

## Implementation Details

The implementation of rank normalization is straightforward:

```r
# Replace counts with intrasample ranks
ranked_data <- apply(data, 2, rank)

# Perform t-test on each feature
results <- apply(ranked_data, 1, function(x) {
  t.test(x ~ group)$p.value
})
```

## Conclusion

Rank normalization offers a simple yet effective approach for microbiome differential abundance analysis. Its ability to control false discoveries while maintaining statistical power makes it a valuable tool for researchers working with microbiome data.

For more details, see our paper in [Briefings in Bioinformatics](https://academic.oup.com/bib/article/22/5/bbab059/6210069).
EOL

cat > _posts/2025-04-15-smoothing-splines.md << 'EOL'
---
layout: post
title: "The Art and Science of Smoothing Splines"
date: 2025-04-15
categories: [Statistical Methods]
---

Smoothing splines are powerful tools for function estimation, but traditional formulations can be difficult to interpret. In this post, I explore the intuition behind smoothing splines and introduce a novel formulation using Lagrangian multipliers that enhances interpretability.

## What Are Smoothing Splines?

Smoothing splines are a method for fitting a smooth curve to data points. They aim to balance two competing goals:

1. **Goodness of fit**: How well the curve fits the observed data points.
2. **Smoothness**: How smooth the resulting curve is, typically measured by the integrated squared second derivative.

The traditional formulation minimizes:

$$
\sum_{i=1}^{n} (y_i - f(x_i))^2 + \lambda \int [f''(x)]^2 dx
$$

Where $\lambda$ is a smoothing parameter that controls the trade-off between fit and smoothness.

## The Interpretation Challenge

While the traditional formulation is mathematically elegant, it can be challenging to interpret the resulting fit in terms of predictor-response relationships. The smoothing parameter $\lambda$ lacks a direct interpretation, and understanding how changes in the input affect the output often requires post-fitting algebraic manipulation.

## Lagrangian Multiplier Formulation

The Lagrangian multiplier formulation reformulates the smoothing spline problem as a constrained optimization:

$$
\min_{f} \int [f''(x)]^2 dx \quad \text{subject to} \quad \sum_{i=1}^{n} (y_i - f(x_i))^2 \leq \delta
$$

This approach has several advantages:

1. **Direct interpretation**: The constraint parameter $\delta$ has a clear interpretation as the maximum allowable deviation from the data.
2. **Accessible predictor-response relationships**: The formulation provides direct access to how changes in the predictor affect the response.
3. **Intuitive parameter selection**: Choosing $\delta$ is often more intuitive than choosing $\lambda$.

## Implementation in the lgspline Package

The `lgspline` R package implements this Lagrangian multiplier formulation, providing a user-friendly interface for fitting smoothing splines with enhanced interpretability.

Example usage:

```r
library(lgspline)

# Generate some example data
set.seed(123)
x <- seq(0, 10, length.out = 100)
y <- sin(x) + rnorm(100, 0, 0.2)
data <- data.frame(x = x, y = y)

# Fit a smoothing spline with lgspline
fit <- lgspline(y ~ x, data = data)

# Plot the results
plot(fit)
```

## Conclusion

The Lagrangian multiplier formulation of smoothing splines offers a fresh perspective that enhances interpretability while preserving the powerful fitting capabilities of traditional smoothing splines. By making the trade-off between fit and smoothness more explicit and interpretable, this approach makes smoothing splines more accessible to researchers across various fields.

Check out the `lgspline` package on [GitHub](https://github.com/matthewlouisdavisBioStat/lgspline) for more information and examples.
EOL

# Create main pages
cat > research.md << 'EOL'
---
layout: page
title: Research
permalink: /research/
---

# Research Interests

My research focuses on developing novel statistical methods for analyzing complex biological data, with a particular emphasis on microbiome data analysis and function estimation.

## Microbiome Data Analysis

Microbiome data present unique analytical challenges due to their high dimensionality, sparsity, and compositional nature. My work in this area focuses on developing robust statistical methods for identifying differentially abundant taxa across experimental conditions.

Key contributions:
- Development of rank normalization as an alternative to traditional normalization factors for microbiome differential abundance analysis
- Rigorous evaluation of statistical methods on simulated and real microbiome datasets
- Implementation of user-friendly software for microbiome data analysis

## Smoothing Splines and Function Estimation

Smoothing splines are powerful tools for estimating unknown functions from noisy data. My research in this area focuses on enhancing the interpretability and accessibility of smoothing splines through novel formulations.

Key contributions:
- Reformulation of smoothing splines using Lagrangian multipliers to enhance interpretability
- Development of the `lgspline` R package for fitting smoothing splines with direct interpretation of predictor-response relationships
- Application of smoothing splines to various biological and biomedical datasets

## Statistical Software Development

I am passionate about creating high-quality, user-friendly statistical software that makes advanced methods accessible to applied researchers. My software development work focuses on R packages for statistical analysis and data visualization.

Key contributions:
- Development of the `lgspline` R package for Lagrangian multiplier smoothing splines
- Implementation of rank normalization methods for microbiome data analysis
- Creation of visualization tools for exploring complex biological data
EOL

cat > projects.md << 'EOL'
---
layout: page
title: Projects
permalink: /projects/
---

# Projects

Here are some of my key research projects and software packages:

{% assign sorted_projects = site.projects | sort: "order" %}
{% for project in sorted_projects %}
<div class="project">
  <h2><a href="{{ project.url }}">{{ project.title }}</a></h2>
  <p>{{ project.description }}</p>
  <div class="project-links">
    {% if project.github %}
    <a href="{{ project.github }}" target="_blank">GitHub</a>
    {% endif %}
    {% if project.website %}
    <a href="{{ project.website }}" target="_blank">Website</a>
    {% endif %}
    {% if project.paper %}
    <a href="{{ project.paper }}" target="_blank">Paper</a>
    {% endif %}
  </div>
  <a href="{{ project.url }}" class="read-more">Read More</a>
</div>
{% endfor %}
EOL

cat > publications.md << 'EOL'
---
layout: page
title: Publications
permalink: /publications/
---

# Publications

{% assign sorted_publications = site.publications | sort: "date" | reverse %}
{% for publication in sorted_publications %}
<div class="publication">
  <h2><a href="{{ publication.url }}">{{ publication.title }}</a></h2>
  <p><strong>Authors:</strong> {{ publication.authors }}</p>
  {% if publication.journal %}
  <p><strong>Journal:</strong> {{ publication.journal }}{% if publication.volume %}, {{ publication.volume }}{% endif %}{% if publication.issue %}({{ publication.issue }}){% endif %}{% if publication.pages %}, {{ publication.pages }}{% endif %}</p>
  {% endif %}
  <p><strong>Date:</strong> {{ publication.date | date: "%Y" }}</p>
  {% if publication.doi %}
  <p><strong>DOI:</strong> <a href="https://doi.org/{{ publication.doi }}" target="_blank">{{ publication.doi }}</a></p>
  {% endif %}
  {% if publication.link %}
  <p><a href="{{ publication.link }}" target="_blank" class="button">View Publication</a></p>
  {% endif %}
</div>
{% endfor %}
EOL

cat > contact.md << 'EOL'
---
layout: page
title: Contact
permalink: /contact/
---

# Contact

I'm always interested in collaborations, discussions, and opportunities to apply statistical methods to interesting problems. Feel free to reach out!

- **Email:** matthew-l-davis@uiowa.edu
- **GitHub:** [matthewlouisdavisBioStat](https://github.com/matthewlouisdavisBioStat)
- **Office:** Department of Biostatistics, University of Iowa

## Research Interests

If you're interested in any of the following areas, I'd be happy to discuss potential collaborations:

- Microbiome data analysis
- Smoothing splines and function estimation
- Statistical software development
- Applications of statistics in biomedical research

## Student Opportunities

I regularly mentor students interested in biostatistics, computational biology, and related fields. If you're a student looking for research opportunities, please email me with your CV and a brief description of your interests.
EOL

# Update the index page
cat > index.md << 'EOL'
---
layout: home
title: Home
---

# Matthew L. Davis, PhD

I am a biostatistician with expertise in statistical methods for microbiome data analysis, smoothing splines, and R package development. My research focuses on developing novel statistical approaches to address complex biological questions.

## Featured Projects

{% assign featured_projects = site.projects | where: "featured", true | sort: "order" %}
{% for project in featured_projects limit: 2 %}
<div class="project-card">
  <h3><a href="{{ project.url }}">{{ project.title }}</a></h3>
  <p>{{ project.description }}</p>
  <a href="{{ project.url }}" class="read-more">Read More</a>
</div>
{% endfor %}

[View All Projects](/projects/)

## Recent Publications

{% assign recent_publications = site.publications | sort: "date" | reverse %}
{% for publication in recent_publications limit: 2 %}
<div class="publication-card">
  <h3><a href="{{ publication.url }}">{{ publication.title }}</a></h3>
  <p><strong>Authors:</strong> {{ publication.authors }}</p>
  {% if publication.journal %}
  <p><strong>Journal:</strong> {{ publication.journal }}{% if publication.volume %}, {{ publication.volume }}{% endif %}{% if publication.issue %}({{ publication.issue }}){% endif %}</p>
  {% endif %}
  <p><strong>Date:</strong> {{ publication.date | date: "%Y" }}</p>
  {% if publication.link %}
  <a href="{{ publication.link }}" target="_blank" class="read-more">View Publication</a>
  {% endif %}
</div>
{% endfor %}

[View All Publications](/publications/)

## Recent Blog Posts

{% for post in site.posts limit: 3 %}
<div class="blog-card">
  <h3><a href="{{ post.url }}">{{ post.title }}</a></h3>
  <p class="post-meta">{{ post.date | date: "%B %-d, %Y" }}</p>
  {{ post.excerpt }}
  <a href="{{ post.url }}" class="read-more">Read More</a>
</div>
{% endfor %}

[View All Blog Posts](/blog/)
EOL

# Create custom styles
mkdir -p assets/css
cat > assets/css/styles.scss << 'EOL'
---
---

@import "minima";

$primary-color: #3498db;
$secondary-color: #2c3e50;
$accent-color: #1abc9c;
$light-bg: #f8f9fa;
$dark-bg: #2c3e50;
$text-color: #333;
$light-text: #f8f9fa;
$border-radius: 5px;
$shadow: 0 4px 6px rgba(0, 0, 0, 0.1);

body {
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  line-height: 1.6;
  color: $text-color;
}

.site-header {
  border-top: 5px solid $primary-color;
  border-bottom: 1px solid lighten($secondary-color, 40%);
}

.site-title {
  font-weight: bold;
  &:hover {
    text-decoration: none;
  }
}

.project, .publication, .blog-card, .project-card, .publication-card {
  margin-bottom: 2rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #eee;
  
  &:last-child {
    border-bottom: none;
  }
}

.project-links {
  margin: 1rem 0;
  
  a {
    display: inline-block;
    margin-right: 1rem;
    padding: 0.25rem 0.75rem;
    background-color: $light-bg;
    border-radius: $border-radius;
    text-decoration: none;
    
    &:hover {
      background-color: darken($light-bg, 5%);
    }
  }
}

.read-more {
  display: inline-block;
  margin-top: 0.5rem;
  color: $primary-color;
  font-weight: bold;
  
  &:hover {
    color: darken($primary-color, 10%);
  }
}

.post-meta {
  color: #666;
  font-size: 0.9rem;
  margin-bottom: 0.5rem;
}

.button {
  display: inline-block;
  background-color: $accent-color;
  color: white;
  padding: 0.5rem 1rem;
  border-radius: $border-radius;
  text-decoration: none;
  font-weight: bold;
  
  &:hover {
    background-color: darken($accent-color, 10%);
    text-decoration: none;
    color: white;
  }
}

pre, code {
  background-color: #f1f1f1;
  border: 1px solid #e1e1e1;
  border-radius: $border-radius;
}

.profile {
  display: flex;
  align-items: center;
  margin-bottom: 2rem;
  
  .profile-img {
    width: 150px;
    height: 150px;
    border-radius: 50%;
    object-fit: cover;
    margin-right: 2rem;
    border: 3px solid $primary-color;
  }
  
  .profile-info {
    flex: 1;
  }
}

.social-links {
  display: flex;
  gap: 1rem;
  margin-top: 1rem;
  
  a {
    color: $primary-color;
    font-size: 1.5rem;
    transition: all 0.3s;
    
    &:hover {
      color: $accent-color;
      transform: translateY(-3px);
    }
  }
}

@media (max-width: 768px) {
  .profile {
    flex-direction: column;
    text-align: center;
    
    .profile-img {
      margin-right: 0;
      margin-bottom: 1rem;
    }
    
    .social-links {
      justify-content: center;
    }
  }
}
EOL

# Add a custom layout for projects
mkdir -p _layouts
cat > _layouts/project.html << 'EOL'
---
layout: default
---

<div class="project-detail">
  <h1>{{ page.title }}</h1>
  
  <div class="project-links">
    {% if page.github %}
    <a href="{{ page.github }}" target="_blank" class="button">GitHub Repository</a>
    {% endif %}
    {% if page.website %}
    <a href="{{ page.website }}" target="_blank" class="button">Project Website</a>
    {% endif %}
    {% if page.paper %}
    <a href="{{ page.paper }}" target="_blank" class="button">Research Paper</a>
    {% endif %}
  </div>
  
  <div class="project-content">
    {{ content }}
  </div>
</div>
EOL

# Add a custom layout for publications
cat > _layouts/publication.html << 'EOL'
---
layout: default
---

<div class="publication-detail">
  <h1>{{ page.title }}</h1>
  
  <p><strong>Authors:</strong> {{ page.authors }}</p>
  
  {% if page.journal %}
  <p><strong>Journal:</strong> {{ page.journal }}{% if page.volume %}, {{ page.volume }}{% endif %}{% if page.issue %}({{ page.issue }}){% endif %}{% if page.pages %}, {{ page.pages }}{% endif %}</p>
  {% endif %}
  
  <p><strong>Date:</strong> {{ page.date | date: "%B %Y" }}</p>
  
  {% if page.doi %}
  <p><strong>DOI:</strong> <a href="https://doi.org/{{ page.doi }}" target="_blank">{{ page.doi }}</a></p>
  {% endif %}
  
  {% if page.link %}
  <p><a href="{{ page.link }}" target="_blank" class="button">View Publication</a></p>
  {% endif %}
  
  <div class="publication-content">
    {{ content }}
  </div>
</div>
EOL

# Create dummy placeholder images
mkdir -p assets/images

# Install dependencies
echo "Installing dependencies..."
bundle install

# Create README
cat > README.md << 'EOL'
# Statistics Research Website

This is a Jekyll-based website for showcasing research, projects, and discussion/posts about statistics.

## Setup

1. Clone this repository
2. Make sure you have Ruby and Jekyll installed
3. Run `bundle install` to install dependencies
4. Run `bundle exec jekyll serve` to start the local development server
5. Visit `http://localhost:4000` to see the website

## Adding Content

### Blog Posts

Add new blog posts to the `_posts` directory with the filename format `YYYY-MM-DD-title.md`.

### Projects

Add new projects to the `_projects` directory.

### Publications

Add new publications to the `_publications` directory.

## Deployment

This website can be deployed to GitHub Pages by pushing to your GitHub repository.

1. Create a new GitHub repository
2. Push this code to the repository
3. Go to repository settings and enable GitHub Pages
4. The website will be available at `https://yourusername.github.io/repositoryname/`

For a custom domain, follow the GitHub Pages documentation.
EOL

# Success message
echo "Website setup complete! 🎉"
echo ""
echo "To start the development server, run:"
echo "  bundle exec jekyll serve"
echo ""
echo "Then visit http://localhost:4000 in your browser to see your website."
echo ""
echo "To deploy to GitHub Pages:"
echo "1. Create a GitHub repository"
echo "2. Push this code to the repository"
echo "3. Enable GitHub Pages in the repository settings"
echo ""
echo "For more information, see the README.md file."
