================================================================================
                         VCDB INTERACTIVE EXPLORER
================================================================================

An interactive web application for exploring security incident data from the
VERIS Community Database (VCDB).


WHAT THIS TOOL DOES
--------------------------------------------------------------------------------

VCDB Explorer allows you to:

  * Filter incidents by country/region, industry sector, attack type, and
    threat actor
  * View breach statistics and breach rates for your selected criteria
  * Explore year-over-year trends in security incidents
  * Identify which attack vectors and threat actors are most common
  * See which data types are most frequently compromised


REQUIREMENTS
--------------------------------------------------------------------------------

  * R (version 4.0 or higher)
  * Required R packages: shiny, tidyverse, DT


INSTALLING R
--------------------------------------------------------------------------------

WINDOWS:

  1. Go to https://cran.r-project.org/
  2. Click "Download R for Windows"
  3. Click "base"
  4. Click "Download R-4.x.x for Windows" (latest version)
  5. Run the downloaded installer
  6. Accept the default installation options

MAC:

  1. Go to https://cran.r-project.org/
  2. Click "Download R for macOS"
  3. Download the appropriate .pkg file for your Mac
  4. Run the installer

OPTIONAL - INSTALL RSTUDIO (RECOMMENDED):

  RStudio provides a more user-friendly interface for R:

  1. Go to https://posit.co/download/rstudio-desktop/
  2. Download RStudio Desktop (Free)
  3. Install it


INSTALLING REQUIRED PACKAGES
--------------------------------------------------------------------------------

Open R or RStudio and run the following command:

    install.packages(c("shiny", "tidyverse", "DT"))

This only needs to be done once. The installation may take a few minutes.


RUNNING THE APPLICATION
--------------------------------------------------------------------------------

OPTION 1: USING RSTUDIO (EASIEST)

  1. Open RStudio
  2. Go to File > Open File
  3. Navigate to the VCDB_Explorer folder and open app.R
  4. Click the "Run App" button in the top-right corner of the editor

OPTION 2: USING R CONSOLE

  1. Open R
  2. Set the working directory to the VCDB_Explorer folder:

         setwd("C:/path/to/VCDB_Explorer")

  3. Run the application:

         shiny::runApp()

OPTION 3: ONE-LINE COMMAND

  In R or RStudio console:

      shiny::runApp("C:/path/to/VCDB_Explorer")

The application will open in your default web browser.


USING THE INTERFACE
--------------------------------------------------------------------------------

FILTERS (LEFT SIDEBAR):

  1. Country/Region - Select geographic focus
       - All Countries (default)
       - United States
       - Europe
       - Asia-Pacific
       - Other Regions

  2. Industry Sector - Filter by industry type
       - Uses NAICS classification codes
       - Healthcare, Government, Finance, etc.

  3. Attack Vectors - Check/uncheck to filter by attack type
       - Hacking, Malware, Social Engineering, Misuse, Physical, Error

  4. Threat Actors - Check/uncheck to filter by actor origin
       - External, Internal, Partner

  5. Year Range - Slide to select time period (2005-2021)

DASHBOARD (MAIN PANEL):

  * Summary Statistics: Organization count, incident count, breach rate
  * Incidents by Year: Stacked bar chart showing breaches vs. non-breach incidents
  * Attack Types: Horizontal bar chart of attack vector frequency
  * Threat Actors: Horizontal bar chart of actor type frequency
  * Data Types Compromised: Table of most frequently compromised data types


UNDERSTANDING THE DATA
--------------------------------------------------------------------------------

DATA SOURCE:

  VCDB (VERIS Community Database) is a collection of publicly reported security
  incidents maintained by the security community. Data is coded using the VERIS
  framework (Vocabulary for Event Recording and Incident Sharing).

IMPORTANT LIMITATIONS:

  1. US-CENTRIC: Approximately 70-80% of incidents are from the United States
     due to:
       - US breach notification laws require public disclosure
       - Primary data sources are English-language news and filings
       - Volunteer contributors are predominantly US/English-speaking

  2. PUBLIC INCIDENTS ONLY: VCDB only includes publicly reported incidents.
     Many incidents go unreported, so actual incident rates are higher.

  3. REPORTING LAG: Recent years (2022+) have incomplete data. It takes months
     or years for incidents to be publicly disclosed, discovered, and added
     to VCDB.

  4. BEST EFFORT ORGANIZATION COUNT: The unique organization count is an
     approximation based on available victim identifiers.

INTERPRETING RESULTS:

  * Use this data for RELATIVE COMPARISONS
    (e.g., "Hacking is more common than Physical in Healthcare")

  * Do NOT use for ABSOLUTE RISK QUANTIFICATION
    (e.g., "My organization has X% chance of breach")

  * Cross-reference with other sources like the Verizon DBIR for validation


FILES INCLUDED
--------------------------------------------------------------------------------

  app.R        The Shiny application code
  vcdb.dat     VCDB incident database
  README.txt   This documentation file (plain text)
  README.md    This documentation file (Markdown format)
  README.html  This documentation file (HTML format - open in browser)


MORE INFORMATION
--------------------------------------------------------------------------------

  VCDB Project:     https://github.com/vz-risk/VCDB
  VERIS Framework:  http://veriscommunity.net/
  Verizon DBIR:     https://www.verizon.com/business/resources/reports/dbir/


TROUBLESHOOTING
--------------------------------------------------------------------------------

"PACKAGE NOT FOUND" ERROR:
  Run: install.packages("package_name") for the missing package.

APP WON'T START:
  Make sure:
    1. Your working directory contains both app.R and vcdb.dat
    2. All required packages are installed
    3. You're using R version 4.0+

CHARTS ARE EMPTY:
  Your filter combination may have returned zero results. Try broadening
  your filters.

BROWSER DOESN'T OPEN:
  Copy the URL shown in the R console (usually http://127.0.0.1:XXXX) and
  paste it in your browser manually.

================================================================================
