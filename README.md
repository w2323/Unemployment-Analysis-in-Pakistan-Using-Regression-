# 📊 Unemployment Analysis in Pakistan Using Regression

[![Python](https://img.shields.io/badge/Python-3.9%2B-blue?logo=python)](https://www.python.org/)
[![R](https://img.shields.io/badge/R-4.x-276DC3?logo=r)](https://www.r-project.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Completed-brightgreen)]()
[![Data Source](https://img.shields.io/badge/Data-World%20Bank%20WDI-orange)](https://databank.worldbank.org/source/world-development-indicators)

> A statistical and machine learning study investigating the structural drivers of unemployment in Pakistan (1960–2024), using **Multiple Linear Regression (MLR)** and **Random Forest** models to identify, quantify, and compare the impact of key macroeconomic and social indicators.

---

## 📌 Table of Contents

- [Overview](#-overview)
- [Motivation](#-motivation)
- [Key Findings](#-key-findings)
- [Dataset](#-dataset)
  - [Variables Description](#variables-description)
  - [Data Cleaning & Preprocessing](#data-cleaning--preprocessing)
- [Methodology](#-methodology)
  - [Exploratory Data Analysis](#exploratory-data-analysis)
  - [Multiple Linear Regression](#1-multiple-linear-regression-mlr)
  - [Random Forest](#2-random-forest)
- [Results](#-results)
  - [Feature Importance](#feature-importance)
  - [Model Performance Comparison](#model-performance-comparison)
- [Visualizations](#-visualizations)
- [Repository Structure](#-repository-structure)
- [Installation & Setup](#-installation--setup)
- [Usage](#-usage)
- [Tech Stack](#-tech-stack)
- [Literature Review Summary](#-literature-review-summary)
- [Limitations](#-limitations)
- [Future Work](#-future-work)
- [Conclusion](#-conclusion)
- [References](#-references)
- [Authors](#-authors)
- [Acknowledgements](#-acknowledgements)
- [License](#-license)

---

## 🧭 Overview

Unemployment remains one of the most persistent and structurally embedded economic challenges in developing economies, and **Pakistan** is a compelling case study. This project analyzes over six decades of macroeconomic data (**1960–2024**) to understand how five key structural forces — **Labor Force Participation, Urbanization, Internet Penetration, Energy Consumption,** and **Foreign Direct Investment (FDI)** — relate to and help predict the national unemployment rate.

The project takes a dual-model approach:

1. **Multiple Linear Regression (MLR)** — for interpretability and coefficient-level insight into direction and magnitude of relationships.
2. **Random Forest Regression** — for predictive power, capturing non-linearities and variable interactions that a linear model cannot.

Model outputs are benchmarked against each other using **MSE**, **RMSE**, and **MAE**, and variable importance is extracted from the Random Forest model to identify the most influential structural drivers.

This was completed as a **Probability & Statistics course project** at the **National University of Computer & Emerging Sciences (FAST-NUCES)**.

---

## 💡 Motivation

Pakistan's labour market has been shaped by decades of population growth, rural-to-urban migration, uneven industrialization, and — more recently — rapid digital transformation. Despite the availability of rich longitudinal data, unemployment analysis in Pakistan is often treated with overly simplistic, single-variable narratives.

This project was motivated by the question:

> *Which structural and economic forces actually explain long-run unemployment trends in Pakistan, and can a flexible, non-linear model out-predict a traditional linear one?*

---

## 🔑 Key Findings

- 📈 **Labor Force Participation** and **Urbanization** show strong **positive** relationships with unemployment — more entrants to the labour force and faster urban migration outpace job creation.
- 🌐 **Internet Penetration** has a **moderate** relationship — a double-edged effect of job creation vs. displacement of traditional-sector workers.
- ⚡ **Energy Consumption** is strongly associated with unemployment and serves as a reliable proxy for overall economic activity.
- 💰 **FDI Inflows** show the **weakest and most inconsistent** relationship — challenging the assumption that foreign investment reliably reduces joblessness.
- 🌲 **Random Forest significantly outperforms MLR**, with a far lower test-set MSE (**0.140 vs. 1.355**), confirming that unemployment dynamics in Pakistan are **non-linear** and driven by interacting structural factors.
- 🥇 Per the Random Forest importance ranking, the top three drivers of unemployment are:
  1. Energy Consumption
  2. Internet Penetration
  3. Labor Force Participation

---

## 🗃 Dataset

**Source:** [World Bank — World Development Indicators (WDI)](https://databank.worldbank.org/source/world-development-indicators)

**Coverage:** Pakistan, annual data from **1960 to 2024**

### Variables Description

| Variable | Role | Description | Unit |
|---|---|---|---|
| `unemployment` | Dependent (Y) | Unemployment as % of total labour force | % |
| `labor_force_participation` | Independent (X₁) | Share of working-age population in the labour force | % |
| `urbanization` | Independent (X₂) | Share of population living in urban areas | % |
| `internet_penetration` | Independent (X₃) | Share of population using the internet | % |
| `energy_consumption` | Independent (X₄) | Energy use per capita | kg of oil equivalent per capita |
| `fdi_inflows` | Independent (X₅) | Net foreign direct investment inflows | % of GDP |

### Data Cleaning & Preprocessing

1. Raw indicators pulled from WDI and merged/aligned by **country** and **year**.
2. Dataset sorted chronologically to preserve the time-series structure.
3. Missing values handled using:
   - **LOCF** — Last Observation Carried Forward (forward fill)
   - **BOCF** — Backward fill (as a secondary pass)
4. Any remaining unfilled gaps were dropped, producing a clean, consistent panel ready for modelling.
5. All variables were **standardized (z-scores)** prior to visual comparison in the box-and-whisker analysis, since each variable is measured on a different scale/unit.

---

## 🧪 Methodology

### Exploratory Data Analysis

#### Box-and-Whisker Analysis
Standardized boxplots were used to compare the distribution and spread of all six variables on a common scale. Key observations:
- Unemployment and Urbanization behave relatively predictably with modest spread.
- Labor Force Participation shows wider variation, reflecting shifting workforce dynamics over 60+ years.
- Internet Penetration and FDI Inflows show the most pronounced outliers — consistent with rapid digital adoption and episodic investment spikes.
- Energy Consumption remains variable but broadly within a normal range.

#### Scatter Plot / Correlation Analysis
Each independent variable was plotted against unemployment with an OLS trend line and Pearson correlation coefficient (*r*) to assess relationship strength and direction prior to model fitting.

### 1. Multiple Linear Regression (MLR)

The regression model is specified as:

```
Unemployment = β0 + β1(LFP) + β2(Urbanization) + β3(Internet) + β4(Energy) + β5(FDI) + ε
```

Where each **βᵢ** coefficient quantifies the expected change in unemployment for a one-unit increase in the corresponding predictor, holding other variables constant:
- **Positive coefficients** → variable pushes unemployment higher
- **Negative coefficients** → variable is associated with lower unemployment

MLR was chosen for its transparency and ease of interpretation, serving as the interpretable baseline model.

### 2. Random Forest

Random Forest is an ensemble learning method that builds a large number of decision trees on bootstrapped samples of the data and averages their predictions. Unlike MLR, it:
- Naturally captures **non-linear relationships**
- Detects **interaction effects** between predictors
- Requires **no strict distributional assumptions** (e.g., linearity, homoscedasticity, normal residuals)
- Provides built-in **variable importance metrics** (`%IncMSE` and `IncNodePurity`)

Random Forest was used as the flexible, high-performance counterpart to the interpretable MLR baseline.

### Evaluation Metrics

Both models were evaluated on a held-out test set using:
- **MSE** — Mean Squared Error
- **RMSE** — Root Mean Squared Error
- **MAE** — Mean Absolute Error

---

## 📈 Results

### Feature Importance

Based on the Random Forest model's `%IncMSE` and `IncNodePurity` rankings, the most influential predictors of unemployment in Pakistan are:

| Rank | Variable | Interpretation |
|---|---|---|
| 1 | Energy Consumption | Strongest proxy for real economic/industrial activity |
| 2 | Internet Penetration | Reflects structural/technological transformation |
| 3 | Labor Force Participation | Captures labour supply pressure |
| 4 | Urbanization | Reflects migration-driven labour market congestion |
| 5 | FDI Inflows | Least predictive — weak, inconsistent effect on jobs |

**Takeaway:** Economic activity levels and technological change are more central to Pakistan's unemployment dynamics than raw investment inflows.

### Model Performance Comparison

| Model | Test Set MSE | Relative Fit |
|---|---|---|
| Multiple Linear Regression | **1.355** | Captures general trend, struggles with fluctuations |
| Random Forest | **0.140** | Tracks both long-run trend and short-term movement closely |

- The MLR model produces smooth, slow-reacting predictions that underfit sudden fluctuations in unemployment.
- The Random Forest model's predicted-vs-actual scatter clusters tightly around the ideal 45° line — a strong visual indicator of predictive accuracy.
- The ~10x lower MSE for Random Forest **confirms that unemployment in Pakistan is a non-linear phenomenon**, driven by interacting structural forces that linear models cannot fully represent.

---

## 🖼 Visualizations

The project report and accompanying analysis include:

- 📦 Standardized Box-and-Whisker plot across all six variables
- 🔵 Scatter plots of Unemployment vs. each independent variable (with OLS trend line & Pearson *r*)
- 🌲 Random Forest variable importance plots (`%IncMSE` and `IncNodePurity`)
- 📉 Actual vs. Predicted time-series plots for MLR, Random Forest, and combined comparison
- 🎯 Actual vs. Predicted scatter plots (test set) for both models
- 📊 Bar chart comparing test-set MSE across models

> See `/figures` or the full project report (`probProjectReport.pdf`) for all plots referenced above.

---

## 📁 Repository Structure

```
unemployment-analysis-pakistan/
│
├── data/
│   ├── raw/                     # Raw WDI extracts
│   └── processed/                # Cleaned, imputed, merged dataset
│
├── notebooks/
│   ├── 01_data_cleaning.ipynb
│   ├── 02_eda_boxplots.ipynb
│   ├── 03_scatter_correlation.ipynb
│   ├── 04_mlr_model.ipynb
│   └── 05_random_forest_model.ipynb
│
├── src/
│   ├── preprocessing.py
│   ├── mlr_model.py
│   ├── random_forest_model.py
│   └── evaluation_metrics.py
│
├── figures/                      # Exported plots (boxplot, scatter, importance, comparison)
│
├── report/
│   └── probProjectReport.pdf     # Full written project report
│
├── requirements.txt
├── README.md
└── LICENSE
```

*(Structure shown reflects a suggested organization; adapt paths to match your actual repo layout.)*

---

## ⚙️ Installation & Setup

### Prerequisites
- Python 3.9+ **or** R 4.x
- pip / conda (Python) or CRAN packages (R)

### Python Setup

```bash
# Clone the repository
git clone https://github.com/<your-username>/unemployment-analysis-pakistan.git
cd unemployment-analysis-pakistan

# Create a virtual environment
python -m venv venv
source venv/bin/activate      # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

**requirements.txt** (example)
```
pandas
numpy
matplotlib
seaborn
scikit-learn
statsmodels
scipy
```

### R Setup (alternative)

```r
install.packages(c("randomForest", "ggplot2", "dplyr", "caret", "Metrics"))
```

---

## ▶️ Usage

```bash
# 1. Clean and preprocess the raw WDI dataset
python src/preprocessing.py --input data/raw/ --output data/processed/dataset.csv

# 2. Run exploratory data analysis (boxplots, scatter plots)
jupyter notebook notebooks/02_eda_boxplots.ipynb

# 3. Fit the Multiple Linear Regression model
python src/mlr_model.py --data data/processed/dataset.csv

# 4. Fit the Random Forest model
python src/random_forest_model.py --data data/processed/dataset.csv

# 5. Compare model performance (MSE, RMSE, MAE)
python src/evaluation_metrics.py
```

---

## 🛠 Tech Stack

| Category | Tools |
|---|---|
| Language | Python / R |
| Data Handling | pandas, NumPy |
| Visualization | matplotlib, seaborn, ggplot2 |
| Modelling | scikit-learn / statsmodels (MLR), randomForest / scikit-learn (Random Forest) |
| Environment | Jupyter Notebook |
| Data Source | World Bank World Development Indicators (WDI) |

---

## 📚 Literature Review Summary

Economic theory frames unemployment as a function of both **supply-side** and **demand-side** labour market forces:

- **Labor Force Participation:** Rising participation increases unemployment when job creation lags behind labour supply growth.
- **Urbanization:** Cities generate employment but also attract migration that intensifies job competition.
- **Internet Penetration:** Digital connectivity creates new job categories while simultaneously displacing workers in traditional industries lacking adaptive skills.
- **Energy Consumption:** Long treated as a proxy for industrial/economic activity, and by extension, job creation capacity.
- **FDI Inflows:** Theoretically expected to reduce unemployment, but real-world impact in Pakistan depends heavily on sector allocation and investment scale.

The consistent conclusion across prior research: unemployment in Pakistan is **not a simple linear problem** — it is structural and shaped by long-term economic transformation.

---

## ⚠️ Limitations

- Annual (not monthly/quarterly) data limits granularity for detecting short-term shocks.
- Imputation (LOCF/BOCF) may smooth over genuine volatility in earlier decades with sparser records.
- Random Forest, while more accurate, is less interpretable than MLR — coefficient-level policy insight is harder to extract.
- Correlation-based relationships (scatter plots, feature importance) do not establish strict causality.
- Only five independent variables are considered; other relevant factors (inflation, education levels, informal sector size, remittances) are not modelled.

---

## 🚀 Future Work

- Incorporate additional predictors (inflation, education attainment, informal economy size, remittance inflows).
- Test alternative non-linear models (Gradient Boosting, XGBoost, Neural Networks) for further performance benchmarking.
- Apply time-series-specific techniques (ARIMA, VAR, Granger causality) to better capture temporal dependencies.
- Extend the analysis to a cross-country panel for comparative regional insight (South Asia).
- Investigate causal inference methods (e.g., instrumental variables) to move beyond correlational findings.

---

## 🏁 Conclusion

This study set out to identify the key drivers of unemployment in Pakistan, and the evidence points to clear structural patterns:

- **Labor Force Participation** and **Urbanization** exert upward pressure on unemployment — labour supply is growing faster than the economy can absorb.
- **Internet Penetration** reflects the ongoing structural/technological transformation of Pakistan's economy.
- **Energy Consumption** emerges as one of the strongest indicators of whether the economy generates sufficient job-creating activity.
- **FDI**, despite theoretical promise, has had a limited and inconsistent effect on employment outcomes.

On the modelling side, **Random Forest decisively outperforms Multiple Linear Regression**, underscoring that Pakistan's unemployment dynamics are governed by **non-linear relationships and variable interactions** that a simple linear model cannot capture.

The broader policy implication: **reducing unemployment in Pakistan requires coordinated action** — economic growth, technological development, and labour market reform must work together, since in a complex economy these forces are deeply interconnected.

---

## 🔗 References

- World Bank — [World Development Indicators](https://databank.worldbank.org/source/world-development-indicators)

---

## 👥 Authors

Project submitted for the **Probability & Statistics** course at **FAST-NUCES**, Section F.
Submitted to: **Ma'am Warda**

| Name | Roll Number |
|---|---|
| Abdullah | 22i-2346 |
| Wasif Mehmood | 24i-0699 |
| Hammad Rasheed | 24i-0703 |

---

## 🙏 Acknowledgements

- Thanks to **Ma'am Warda** for guidance and supervision throughout this project.
- Data made publicly available by the **World Bank** via the World Development Indicators database.

---

## 📄 License

This project is released under the [MIT License](LICENSE) — feel free to use, modify, and build upon this work with attribution.

---

<p align="center">
  <i>Made with 📊 and a lot of coffee — National University of Computer & Emerging Sciences</i>
</p>
