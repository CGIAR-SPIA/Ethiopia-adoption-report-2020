# Ethiopia-adoption-report-2020
Welcome to this repository, which contains the replication files for **[Shining a Brighter Light: Comprehensive Evidence on Adoption and Diffusion of CGIAR-Related Innovations in Ethiopia](https://iaes.cgiar.org/spia/publications/shining-brighter-light-comprehensive-evidence-adoption-and-diffusion-cgiar)** (SPIA Synthesis Report, October 2020) by Frederic Kosmowski, Solomon Alemu, Paola Mallia, James Stevenson, and Karen Macours.

This repository provides the code and supporting data needed to reproduce the tables and figures in the Ethiopia synthesis report. Using data from the Ethiopian Socioeconomic Survey (ESS), the research documents adoption patterns across innovations spanning:

- Animal agriculture
- Crop germplasm improvement
- Natural resource management
- Policies and markets interventions

The repo includes the following folders:

```
ethiopia-adoption-report-2020/
├── data/
│   ├── raw_data/          # ESS survey data  
│   └── report_data/         # contains all the procesed data 
├── scripts/
│   ├── 1_master.do       # Master Stata script (runs all the do files)
│   ├── do_files/         # Individual Stata analysis scripts
│   ├── Tabs.R           # R script for DNA fingerprinting tables
│   └── Location_Matching.R  # R script for spatial analysis
├── outputs/
│   ├── tables/          # Placeholder for generated tables (Excel format)
│   ├── figures/         # Placeholder for generated Maps and visualizations
└── README.md`
```
Scripts Organization

| Script File | Purpose | Tables Generated | Figures Generated |
|:------------|:--------|:----------------:|:-----------------:|
| `1_master.do` |runs all Stata analysis scripts in the correct order | Tables 2, 9, 13-16, 17-20, 22, 28-41 | - |
| `Tabs.R` | DNA fingerprinting analysis | 10, 11, 12 | 4, 9 |
| `Location_Matching.R` | Spatial analysis & mapping | 31, 32 | 5, 6, 7, 8 |

###  Getting Started
## Prerequisites

- Stata 15+ with required dependencies 
- R 4.0+ with required packages
  
**Dependencies**

- **Stata scripts**: follows a modular analysis pipeline structure with a master script  `1_master.do` - this executes the entire pipeline and generates all Stata outputs. If running specific components, run individual scripts in order specified.

  **Before Running the scripts**

  1. Clone this repository to your local machine
  2. Open the main `master.do` file and update parent directory with your local path:

     `cd "YOUR/PATH/TO/Ethiopia-adoption-report-2020"`
- **R scripts**:  run independently with your working directory set  to you parent directory: `cd "YOUR/PATH/TO/Ethiopia-adoption-report-2020"`
- Tables 1, 4-8, 21, 23-27 come from external sources (**[Stocktake document - SPIA Ethiopia Report](https://cgspace.cgiar.org/items/12ee33af-4d8e-4c72-baca-599a994ecbda)**,  ESS questionnaires, variety registries in the report Appendices)

# Citation

Kosmowski, F., Alemu, S., Mallia, P., Stevenson, J., & Macours, K. (2020). 
Shining a Brighter Light: Comprehensive Evidence on Adoption and Diffusion of 
CGIAR-related Innovations in Ethiopia. SPIA Synthesis Report. Rome: Standing 
Panel on Impact Assessment (SPIA).

# Contact & Support

- Primary Contact: SPIA (spia@cgiar.org) 

#  Acknowledgments

We thank the contributors acknowledged in the report, please see the report linked above.
