# Ethiopia-adoption-report-2020
Welcome to this repository, which contains the replication files for **[Shining a Brighter Light: Evidence on Adoption and Diffusion of CGIAR-Related Innovations in Ethiopia](https://iaes.cgiar.org/spia/publications/shining-brighter-light-comprehensive-evidence-adoption-and-diffusion-cgiar)** (SPIA Synthesis Report, October 2020) by Frederic Kosmowski, Solomon Alemu, Paola Mallia, James Stevenson, and Karen Macours.

This repository provides the code and supporting data needed to reproduce the tables and figures in the Ethiopia synthesis report. Using data from the Ethiopian Socioeconomic Survey (ESS), the research documents adoption patterns across 19 innovations spanning:

- **Animal agriculture** (crossbred livestock, artificial insemination, improved forages)
- **Crop germplasm improvement** (improved varieties identified through DNA fingerprinting and visual aids)
- **Natural resource management** (soil conservation, irrigation, conservation agriculture)
- **Policy influences** (safety net programs, water user associations)

# Getting Started
## Prerequisites

- Stata 15+ (for main analysis)
- R 4.0+ with packages: , ggplot2, dplyr


The repo includes the following folders:

```
ethiopia-adoption-report-2020/
├── data/
│   ├── raw_data/          # Original ESS survey data  ????
│   ├── processed_data/    # Cleaned and merged datasets ???
│   └── report_data/         # DNA fingerprinting data ???
├── scripts/
│   ├── 1_master.do       # Master Stata script (runs all the do files scripts)
│   ├── do_files/         # Individual Stata analysis scripts
│   ├── Tabs.R           # R script for DNA fingerprinting tables
│   └── Location_Matching.R  # R script for spatial analysis
├── outputs/
│   ├── tables/          # Generated tables (Excel format)
│   ├── figures/         # Maps and visualizations
├── documentation/          **any of this that we need to include** 
│   ├── questionnaires/  # ESS survey instruments ??? 
│   └── methodology/    # Technical notes
└── README.md`
```
Script Organization

| Script File | Purpose | Tables Generated | Figures Generated |
|:------------|:--------|:----------------:|:-----------------:|
| `1_master.do` |runs all Stata analysis scripts in the correct order | All Stata tables | - |
| `Tabs.R` | DNA fingerprinting analysis | 10, 11, 12 | 4, 9 |
| `Location_Matching.R` | Spatial analysis & mapping | 31, 32 | 5, 6, 7, 8 |

### Dependencies

- **Stata scripts**: follows a modular analysis pipeline structure with a master script  `1_master.do` - this executes the entire pipeline and generates all Stata outputs. If running specific components, run individual scripts in order specified.
- **R scripts**:  run independently


# Survey Coverage

- ESS3 (2015/16): **290** enumeration areas, 3,235 rural households
- ESS4 (2018/19): **264** enumeration areas, 2,899 rural households


# Citation

Kosmowski, F., Alemu, S., Mallia, P., Stevenson, J., & Macours, K. (2020). 
Shining a Brighter Light: Comprehensive Evidence on Adoption and Diffusion of 
CGIAR-related Innovations in Ethiopia. SPIA Synthesis Report. Rome: Standing 
Panel on Impact Assessment (SPIA).

# Contact & Support

- Primary Contact: Standing Panel on Impact Assessment (SPIA) Fredric ??
- Technical Issues/Repository Issues: Sophia/Milcah??
- Data Questions: Refer to original ESS documentation??

# Funding Acknowledgments

This work was supported by the CGIAR Standing Panel on Impact Assessment (SPIA) in partnership with the Ethiopian Central Statistical Agency and the World Bank Living Standards Measurement Study team.
