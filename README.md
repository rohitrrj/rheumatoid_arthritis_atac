# Rheumatoid Arthritis ATAC-seq Visualization App
![Docker](https://img.shields.io/badge/docker-ready-blue.svg)
![R-Shiny](https://img.shields.io/badge/R--Shiny-app-brightgreen.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

An interactive web application for visualizing and analyzing ATAC-seq data from rheumatoid arthritis studies. This application provides a user-friendly interface to explore chromatin accessibility patterns in the context of autoimmune disease.

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [Data Description](#data-description)
- [Docker Deployment](#docker-deployment)
- [Usage Guide](#usage-guide)
- [Configuration](#configuration)
- [Contributing](#contributing)

## Overview
This Shiny application enables researchers to explore and visualize ATAC-seq data from rheumatoid arthritis studies. It integrates with processed data from the [ATACseq_Pipeline](../ATACseq_Pipeline) to provide interactive visualization and analysis capabilities.

## Features
- Interactive visualization of chromatin accessibility data
- Differential accessibility analysis between conditions
- Integration with disease-specific annotations
- Dynamic filtering and sorting capabilities
- Statistical analysis tools
- Data export functionality
- Customizable visualization parameters

## Quick Start

Using Docker:
```bash
docker pull rohitrrj/ra-atac-viz
docker run -p 3838:3838 rohitrrj/ra-atac-viz
```

Access the application at: http://localhost:3838

## Installation

### Local Installation
1. Clone the repository:
```bash
git clone https://github.com/rohitrrj/rheumatoid_arthritis_atac.git
cd rheumatoid_arthritis_atac
```

2. Install R dependencies:
```R
install.packages(c(
  "shiny",
  "ggplot2",
  "DT",
  "plotly",
  "dplyr",
  "tidyr"
))
```

3. Run the application:
```R
shiny::runApp("app")
```

## Data Description

### Input Data Format
- Processed ATAC-seq peak files
- Differential accessibility results
- Gene annotations and genomic features
- Clinical metadata

### Data Structure
```
app/
├── data/
│   ├── peak_data/
│   ├── annotations/
│   └── metadata/
└── www/
    └── documentation/
```

## Docker Deployment

### Building the Image
```dockerfile
FROM rocker/shiny:4.1.0

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-gnutls-dev \
    libssl-dev \
    libxml2-dev

# Copy application files
COPY app /srv/shiny-server/app
COPY shiny-server.sh /usr/bin/shiny-server.sh
COPY shiny-customized.config /etc/shiny-server/shiny-server.conf

# Set permissions
RUN chmod +x /usr/bin/shiny-server.sh

# Expose port
EXPOSE 3838

# Start Shiny server
CMD ["/usr/bin/shiny-server.sh"]
```

### Running the Container
```bash
# Build image
docker build -t ra-atac-viz .

# Run container
docker run -d \
  -p 3838:3838 \
  --name ra-atac-viz \
  ra-atac-viz
```

## Usage Guide

1. **Data Loading**
   - Select sample groups
   - Choose analysis parameters
   - Import custom annotations

2. **Visualization Options**
   - Peak browser view
   - Heatmap visualization
   - Differential accessibility plots
   - Gene-centric analysis

3. **Analysis Features**
   - Statistical testing
   - Pathway enrichment
   - Region annotation
   - Data filtering

4. **Export Options**
   - Download plots
   - Export data tables
   - Generate reports

## Configuration

### Application Settings
Modify `app/app.R` for:
```R
# App configuration
options(
  shiny.maxRequestSize = 100*1024^2,
  shiny.plot.width = 800,
  shiny.plot.height = 600
)

# Analysis parameters
PEAK_THRESHOLD = 0.05
MIN_FOLD_CHANGE = 1.5
```

### Server Configuration
Edit `shiny-customized.config`:
```
run_as shiny;
preserve_logs true;
access_log /var/log/shiny-server/access.log tiny;
server {
  listen 3838;
  location / {
    site_dir /srv/shiny-server/app;
    log_dir /var/log/shiny-server;
    directory_index on;
  }
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

### Development Guidelines
- Follow R code style guidelines
- Add unit tests for new features
- Update documentation
- Test Docker deployment

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Applications
This visualization tool has been used in the following publications:

1. "Epigenetic signature of PD-1+ TCF1+ CD8 T cells that act as resource cells during chronic viral infection"
   - *Proc Natl Acad Sci U S A*. 2022 Feb 22;119(8):e2117314119
   - DOI: [10.1073/pnas.2117314119](https://doi.org/10.1073/pnas.2117314119)
   - PMID: [35085847](https://pubmed.ncbi.nlm.nih.gov/35085847)
   - Used for analyzing chromatin accessibility in autoimmune disease contexts

2. "Loss of T cell progenitor reprogramming potential in aging bone marrow niches"
   - *JCI Insight*. 2020 Apr 9;5(7):e134356
   - DOI: [10.1172/jci.insight.134356](https://doi.org/10.1172/jci.insight.134356)
   - PMID: [32191644](https://pubmed.ncbi.nlm.nih.gov/32191644/)
   - PMCID: [PMC7101137](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7101137/)
   - Applied for studying immune cell chromatin accessibility patterns

Code availability:
⭐ [rohitrrj/rheumatoid_arthritis_atac](https://github.com/rohitrrj/rheumatoid_arthritis_atac) - Interactive tool for analyzing ATAC-seq data in rheumatoid arthritis

## Related Projects
- [ATACseq_Pipeline](../ATACseq_Pipeline)
- [macrophage_atac](../macrophage_atac)
- [t_cell_activation_atac](../t_cell_activation_atac)

## Acknowledgments
- Built with R Shiny framework
- Data processing pipeline: ATACseq_Pipeline
- Supporting institutions and funding
