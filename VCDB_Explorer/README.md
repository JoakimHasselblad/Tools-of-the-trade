# VCDB Interactive Explorer

An interactive web application for exploring security incident data from the VERIS Community Database (VCDB).

## What This Tool Does

VCDB Explorer allows you to:
- Filter incidents by country/region, industry sector, attack type, and threat actor
- View breach statistics and breach rates for your selected criteria
- Explore year-over-year trends in security incidents
- Identify which attack vectors and threat actors are most common
- See which data types are most frequently compromised

## Requirements

- **R** (version 4.0 or higher)
- Required R packages: `shiny`, `tidyverse`, `DT`

## Installing R

### Windows

1. Go to https://cran.r-project.org/
2. Click "Download R for Windows"
3. Click "base"
4. Click "Download R-4.x.x for Windows" (latest version)
5. Run the downloaded installer
6. Accept the default installation options

### Mac

1. Go to https://cran.r-project.org/
2. Click "Download R for macOS"
3. Download the appropriate .pkg file for your Mac
4. Run the installer

### Optional: Install RStudio (Recommended)

RStudio provides a more user-friendly interface for R:
1. Go to https://posit.co/download/rstudio-desktop/
2. Download RStudio Desktop (Free)
3. Install it

## Installing Required Packages

Open R or RStudio and run the following command:

```r
install.packages(c("shiny", "tidyverse", "DT"))
```

This only needs to be done once. The installation may take a few minutes.

## Running the Application

### Option 1: Using RStudio (Easiest)

1. Open RStudio
2. Go to File > Open File
3. Navigate to the `VCDB_Explorer` folder and open `app.R`
4. Click the "Run App" button in the top-right corner of the editor

### Option 2: Using R Console

1. Open R
2. Set the working directory to the VCDB_Explorer folder:
   ```r
   setwd("C:/path/to/VCDB_Explorer")
   ```
3. Run the application:
   ```r
   shiny::runApp()
   ```

### Option 3: One-Line Command

In R or RStudio console:
```r
shiny::runApp("C:/path/to/VCDB_Explorer")
```

The application will open in your default web browser.

## Using the Interface

### Filters (Left Sidebar)

1. **Country/Region**: Select geographic focus
   - All Countries (default)
   - United States
   - Europe
   - Asia-Pacific
   - Other Regions

2. **Industry Sector**: Filter by industry type
   - Uses NAICS classification codes
   - Healthcare, Government, Finance, etc.

3. **Attack Vectors**: Check/uncheck to filter by attack type
   - Hacking, Malware, Social Engineering, Misuse, Physical, Error

4. **Threat Actors**: Check/uncheck to filter by actor origin
   - External, Internal, Partner

5. **Year Range**: Slide to select time period (2005-2021)

### Dashboard (Main Panel)

- **Summary Statistics**: Organization count, incident count, breach rate
- **Incidents by Year**: Stacked bar chart showing breaches vs. non-breach incidents
- **Attack Types**: Horizontal bar chart of attack vector frequency
- **Threat Actors**: Horizontal bar chart of actor type frequency
- **Data Types Compromised**: Table of most frequently compromised data types

## Understanding the Data

### Data Source

VCDB (VERIS Community Database) is a collection of publicly reported security incidents maintained by the security community. Data is coded using the VERIS framework (Vocabulary for Event Recording and Incident Sharing).

### Important Limitations

1. **US-Centric**: Approximately 70-80% of incidents are from the United States due to:
   - US breach notification laws require public disclosure
   - Primary data sources are English-language news and filings
   - Volunteer contributors are predominantly US/English-speaking

2. **Public Incidents Only**: VCDB only includes publicly reported incidents. Many incidents go unreported, so actual incident rates are higher.

3. **Reporting Lag**: Recent years (2022+) have incomplete data. It takes months or years for incidents to be publicly disclosed, discovered, and added to VCDB.

4. **Best Effort Organization Count**: The unique organization count is an approximation based on available victim identifiers.

### Interpreting Results

- Use this data for **relative comparisons** (e.g., "Hacking is more common than Physical in Healthcare")
- Do NOT use for **absolute risk quantification** (e.g., "My organization has X% chance of breach")
- Cross-reference with other sources like the Verizon DBIR for validation

## Files Included

| File | Description |
|------|-------------|
| `app.R` | The Shiny application code |
| `vcdb.dat` | VCDB incident database |
| `README.md` | This documentation file |

## More Information

- VCDB Project: https://github.com/vz-risk/VCDB
- VERIS Framework: http://veriscommunity.net/
- Verizon DBIR: https://www.verizon.com/business/resources/reports/dbir/

## Troubleshooting

### "Package not found" error
Run: `install.packages("package_name")` for the missing package.

### App won't start
Make sure:
1. Your working directory contains both `app.R` and `vcdb.dat`
2. All required packages are installed
3. You're using R version 4.0+

### Charts are empty
Your filter combination may have returned zero results. Try broadening your filters.

### Browser doesn't open
Copy the URL shown in the R console (usually http://127.0.0.1:XXXX) and paste it in your browser manually.
