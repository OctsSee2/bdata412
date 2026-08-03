# Question
 - What jobs are best in which states ?
## Problem
 - With major shifts occurring in the US job market due to AI disruption, many job seekers may be left uninformed about the true state of various occupations across the US.
 - Our dashboard aims to allow for those individuals to research their own region's occupation/industry level data trends to see which ones are experiencing a boom, bust, or stagnation in terms of availability or pay.
 - The level of detail scales from national, to state specific, to city/metro-area specific levels to allow for very precise job statistics for any individual living in a populated area of the US.
 - This also allows for public policy officials or analysts to gain industry and occupational insights for data-driven decision making as it will allow for convenient access of region-bounded industry and occupation data.

# Stakeholders
## Primary
 - American job seekers
    - Specifically those who want to find out if an industry or occupation's pay or availability has changed in the past few years
## Secondary
 - Public policy officials or analysts
    - Specifically those who want to analyze state-by-state occupation related trends to gauge national economic health

# Columns of interest
## Classification
 - `AREA_TYPE`:
    - Filters by broad categories of levels of detail such as: national, state, US territory, metro area, or non-metro area
 - `AREA`:
    - Filters by specific region (individual states, individual US territories, individual (non)metro areas)
 - `NAICS`:
    - Filters by specific industry (as classified by the North American Industry Classification System)
 - `OWN_CODE`:
    - Filters by government ownership type (federal, state, local, private, etc...)
 - `OCC_CODE`:
    - Filters by specific occupation
 - `O_GROUP`:
    - Filters by occupational level of detail (major, minor, detailed)
## Numeric
 - `TOT_EMP`:
    - Total employment count for the specified occupation for specified region
 - `JOBS_1000`:
    - Frequency of total jobs in the specified region are of the specified occupation
 - `LOC_QUOTIENT`:
    - Relatively how common this specified occupation in the specified region relative its national frequency
 - `PCT_TOTAL`:
    - Share of this industry that this specified occupation takes up (not region bounded)
 - `PCT_RPT`:
    - Share of this industry's business locations that has >=1 employee working as this specified occupation (not region bounded)
 - `H_MEAN`:
    - Hourly wage average
 - `H_MEDIAN`:
    - Hourly wage median
 - `A_MEAN`:
    - Annual wage average
 - `A_MEDIAN`:
    - Annual wage median

# Planned methodology
 - Chloropleth map of increasing LODs as zoom progress
    - Color of each region on the map is determined by dropdown menus specifing target occupations or industries
 - Pop-up window or dedicated column for displaying detailed graphs of a region once it is clicked on
 - Sliders for adjusting reporting year
 - Dropdown menus for filtering by ownership type, industry, etc...