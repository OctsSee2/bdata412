# Important !!
 - The dataset is more like several datasets smashed together, so doing analysis without filtering by specific columns will lead to inaccurate results

|Field|Description (my interpretation)|Description (original)|
|-|-|-|
|area|99 => entire US, otherwise are various code identifying states, metro-areas, and non-metro areas|U.S. (99), state FIPS code, Metropolitan Statistical Area (MSA) code, or OEWS-specific nonmetropolitan area code|
|area_title|Human readable ver. of the above column|Area name|
|area_type|1 => **entire US**, 2 => **state**, 3 => **US territory**, 4 => **metro-area**, 5 => **non-metro-area**|Area type: 1= U.S.; 2= State; 3= U.S. Territory; 4= Metropolitan Statistical Area (MSA); 6= Nonmetropolitan Area|
|prim_state|State abbrev. that this row belongs to (or `US` if row is for entire US)|The primary state for the given area. "US" is used for the national estimates.|
|naics|NAICS code for this row's industry|North American Industry Classification System (NAICS) code for the given industry|
|naics_title|Human readable ver. of the above column|North American Industry Classification System (NAICS) title for the given industry|
|i_group|String for the industry classification level for this row|Industry level. Indicates cross-industry or NAICS sector, 3-digit, 4-digit, 5-digit, or 6-digit industry. For industries that OEWS no longer publishes at the 4-digit NAICS level, the “4-digit” designation indicates the most detailed industry breakdown available: either a standard NAICS 3-digit industry or an OEWS-specific combination of 4-digit industries. Industries that OEWS has aggregated to the 3-digit NAICS level (for example, NAICS 327000) will appear twice, once with the “3-digit” and once with the “4-digit” designation.|
|own_code|Code for ownership type for this row|Ownership type: 1= Federal Government; 2= State Government; 3= Local Government; 123= Federal, State, and Local Government; 235=Private, State, and Local Government; 35 = Private and Local Government; 5= Private; 57=Private, Local Government Gambling Establishments (Sector 71), and Local Government Casino Hotels (Sector 72); 58= Private plus State and Local Government Hospitals; 59= Private and Postal Service; 1235= Federal, State, and Local Government and Private Sector|
|occ_code|Code for the job for this row|The 6-digit Standard Occupational Classification (SOC) code or OEWS-specific code for the occupation|
|occ_title|Human readable ver. of the above column|SOC title or OEWS-specific title for the occupation|
|o_group|(**IMPORTANT** use `detailed` for finding rows for individual, specific jobs)String for how detailed or broad the group for this row is|SOC occupation level. For most occupations, this field indicates the standard SOC major, minor, broad, and detailed levels, in addition to all-occupations totals. For occupations that OEWS no longer publishes at the SOC detailed level, the “detailed” designation indicates the most detailed data available: either a standard SOC broad occupation or an OEWS-specific combination of detailed occupations. Occupations that OEWS has aggregated to the SOC broad occupation level will appear in the file twice, once with the “broad” and once with the “detailed” designation.|
|tot_emp|Total employed count for this row|Estimated total employment rounded to the nearest 10 (excludes self-employed).|
|emp_prse|Standard error value for this row's employment estimate|Percent relative standard error (PRSE) for the employment estimate. PRSE is a measure of model error, expressed as a percentage of the corresponding estimate. Model error arises when inferences about a population are made from a survey of selected members of that population, instead of data from all members of the population. Estimates with lower PRSEs are typically more precise in the presence of model error.|
|jobs_1000|How many jobs out of 1000 jobs in this row's region are of this row's specific job|The number of jobs (employment) in the given occupation per 1,000 jobs in the given area. Only available for the state and MSA estimates; otherwise, this column is blank. 
|loc_quotient|How more or less common is this row's specific job for this row's region compared with the national avg ? (1.0 => roughly same as national avg, <1.0 => less common than national avg, >1.0 more common than national avg)|The location quotient represents the ratio of an occupation’s share of employment in a given area to that occupation’s share of employment in the U.S. as a whole. For example, an occupation that makes up 10 percent of employment in a specific metropolitan area compared with 2 percent of U.S. employment would have a location quotient of 5 for the area in question. Only available for the state, metropolitan area, and nonmetropolitan area estimates; otherwise, this column is blank.|
|pct_total|Percentage of this row's region/industry that this row's detailed/major job group occupies|Percent of industry employment in the given occupation. Percents may not sum to 100 because the totals may include data for occupations that could not be published separately. Only available for the national industry estimates; otherwise, this column is blank.|
|pct_rpt|(only contains values on *national* + *detailed jobs* rows) Percentage of business locations in this row's specific industry that are belong to this row's specific job|Percent of establishments reporting the given occupation for the cell. Only available for the national industry estimates; otherwise, this column is blank.|
|h_mean||Mean hourly wage|
|a_mean||Mean annual wage|
|mean_prse|Standard error value for this row's avg wage value|Percent relative standard error (PRSE) for the mean wage estimate. PRSE is a measure of model error, expressed as a percentage of the corresponding estimate. Model error arises when inferences about a population are made from a survey of selected members of that population, instead of data from all members of the population. Estimates with lower PRSEs are typically more precise in the presence of model error.|
|h_pct10||Hourly 10th percentile wage|
|h_pct25||Hourly 25th percentile wage|
|h_median||Hourly median wage (or the 50th percentile)|
|h_pct75||Hourly 75th percentile wage|
|h_pct90||Hourly 90th percentile wage|
|a_pct10||Annual 10th percentile wage|
|a_pct25||Annual 25th percentile wage|
|a_median||Annual median wage (or the 50th percentile)|
|a_pct75||Annual 75th percentile wage|
|a_pct90||Annual 90th percentile wage|
|annual|Whether or not the annual wages are available|Contains "TRUE" if only annual wages are released. The OEWS program releases only annual wages for some occupations that typically work fewer than 2,080 hours per year, but are paid on an annual basis, such as teachers, pilots, and athletes.|
|hourly|Whether or not the hourly wages are available|Contains "TRUE" if only hourly wages are released. The OEWS program releases only hourly wages for some occupations that typically work fewer than 2,080 hours per year and are paid on an hourly basis, such as actors, dancers, and musicians and singers.|
