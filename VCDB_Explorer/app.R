# VCDB Interactive Explorer
# A Shiny web application for exploring security incident data

# ============================================================================
# SETUP
# ============================================================================

library(shiny)
library(tidyverse)
library(DT)

# Load VCDB data
load("vcdb.dat")

# Filter to mature data years only (2005-2021)
# Recent years have incomplete data due to reporting lag
vcdb_data <- vcdb %>%
  filter(timeline.incident.year >= 2005, timeline.incident.year <= 2021)

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# Helper function to count rows with any TRUE in selected columns
count_any_true <- function(data, prefix) {
  cols <- select(data, starts_with(prefix))
  if (ncol(cols) == 0) return(0)
  cols_numeric <- mutate(cols, across(everything(), ~as.numeric(. == TRUE)))
  sum(rowSums(cols_numeric, na.rm = TRUE) > 0)
}

# Helper function to check if a row has any TRUE in columns matching prefix
has_any_true <- function(data, prefix) {
  cols <- select(data, starts_with(prefix))
  if (ncol(cols) == 0) return(rep(FALSE, nrow(data)))
  cols_numeric <- mutate(cols, across(everything(), ~as.numeric(. == TRUE)))
  rowSums(cols_numeric, na.rm = TRUE) > 0
}

# ============================================================================
# LOOKUP TABLES
# ============================================================================

# Industry sector lookup (NAICS codes)
industry_choices <- c(
 "All Sectors" = "all",
 "Healthcare (62)" = "62",
 "Government (92)" = "92",
 "Finance & Insurance (52)" = "52",
 "Information/Tech (51)" = "51",
 "Retail Trade (44-45)" = "44",
 "Professional Services (54)" = "54",
 "Manufacturing (31-33)" = "31",
 "Education (61)" = "61",
 "Accommodation & Food (72)" = "72",
 "Transportation (48-49)" = "48",
 "Other" = "other"
)

# Country/Region groupings
# VCDB stores countries as boolean columns: victim.country.US, victim.country.GB, etc.
us_patterns <- c("victim.country.US")
europe_patterns <- c("victim.country.GB", "victim.country.UK", "victim.country.DE",
                     "victim.country.FR", "victim.country.IT", "victim.country.ES",
                     "victim.country.NL", "victim.country.BE", "victim.country.CH",
                     "victim.country.AT", "victim.country.SE", "victim.country.NO",
                     "victim.country.DK", "victim.country.FI", "victim.country.IE",
                     "victim.country.PL", "victim.country.PT", "victim.country.CZ",
                     "victim.country.GR", "victim.country.HU", "victim.country.RO",
                     "victim.country.BG", "victim.country.HR", "victim.country.SK",
                     "victim.country.SI", "victim.country.LT", "victim.country.LV",
                     "victim.country.EE", "victim.country.LU", "victim.country.UA")
apac_patterns <- c("victim.country.AU", "victim.country.NZ", "victim.country.JP",
                   "victim.country.CN", "victim.country.KR", "victim.country.IN",
                   "victim.country.SG", "victim.country.HK", "victim.country.TW",
                   "victim.country.TH", "victim.country.MY", "victim.country.ID",
                   "victim.country.PH", "victim.country.VN", "victim.country.PK")

region_choices <- c(
  "All Countries" = "all",
  "United States" = "us",
  "Europe" = "europe",
  "Asia-Pacific" = "apac",
  "Other Regions" = "other"
)

# ============================================================================
# UI DEFINITION
# ============================================================================

ui <- fluidPage(

  # Application title
  titlePanel("VCDB Interactive Explorer"),

  # Sidebar layout
  sidebarLayout(

    # Sidebar panel with filters
    sidebarPanel(
      width = 3,

      # Country/Region filter
      selectInput(
        "region",
        "Country/Region:",
        choices = region_choices,
        selected = "all"
      ),

      # Industry sector filter
      selectInput(
        "sector",
        "Industry Sector:",
        choices = industry_choices,
        selected = "all"
      ),

      hr(),

      # Attack vectors (action types) - alphabetically sorted
      checkboxGroupInput(
        "actions",
        "Attack Vectors:",
        choices = c(
          "Error" = "error",
          "Hacking" = "hacking",
          "Malware" = "malware",
          "Misuse" = "misuse",
          "Physical" = "physical",
          "Social Engineering" = "social"
        ),
        selected = c("error", "hacking", "malware", "misuse", "physical", "social")
      ),
      # Select all / Deselect all for attack vectors
      fluidRow(
        column(6, actionLink("select_all_actions", "Select all")),
        column(6, actionLink("deselect_all_actions", "Deselect all"))
      ),

      hr(),

      # Threat actors
      checkboxGroupInput(
        "actors",
        "Threat Actors:",
        choices = c(
          "External" = "external",
          "Internal" = "internal",
          "Partner" = "partner"
        ),
        selected = c("external", "internal", "partner")
      ),
      # Select all / Deselect all for threat actors
      fluidRow(
        column(6, actionLink("select_all_actors", "Select all")),
        column(6, actionLink("deselect_all_actors", "Deselect all"))
      ),

      hr(),

      # Year range
      sliderInput(
        "years",
        "Year Range:",
        min = 2005,
        max = 2021,
        value = c(2005, 2021),
        step = 1,
        sep = ""
      ),

      hr(),

      # Data note
      helpText(
        "Note: Data limited to 2005-2021 due to reporting lag in recent years."
      )
    ),

    # Main panel with outputs
    mainPanel(
      width = 9,

      # Summary statistics
      fluidRow(
        column(12,
          wellPanel(
            h4("Summary Statistics"),
            htmlOutput("summary_stats")
          )
        )
      ),

      # Charts row 1
      fluidRow(
        column(12,
          h4("Incidents by Year"),
          plotOutput("year_chart", height = "300px")
        )
      ),

      # Charts row 2
      fluidRow(
        column(6,
          h4("Attack Types"),
          plotOutput("action_chart", height = "300px")
        ),
        column(6,
          h4("Threat Actors"),
          plotOutput("actor_chart", height = "300px")
        )
      ),

      # Data types table
      fluidRow(
        column(12,
          h4("Data Types Compromised"),
          DTOutput("data_types_table")
        )
      ),

      # Methodology note
      fluidRow(
        column(12,
          hr(),
          h4("About This Data"),
          wellPanel(
            p(strong("Data Source:"), " VERIS Community Database (VCDB) - a collection of publicly reported security incidents."),
            p(strong("Geographic Coverage:"), " Data is heavily US-centric (~70-80%) due to US breach notification laws and English-language sources. International incidents are underrepresented."),
            p(strong("Time Period:"), " Analysis limited to 2005-2021. Recent years (2022+) have incomplete data due to reporting lag - incidents take months or years to be publicly disclosed and added to the database."),
            p(strong("Limitations:"), " VCDB only includes publicly reported incidents. Actual incident rates are likely higher. Use this data for relative comparisons, not absolute risk quantification."),
            p(strong("More Information:"),
              tags$a(href = "https://github.com/vz-risk/VCDB", "VCDB GitHub", target = "_blank"),
              " | ",
              tags$a(href = "https://www.verizon.com/business/resources/reports/dbir/", "Verizon DBIR", target = "_blank")
            )
          )
        )
      )
    )
  )
)

# ============================================================================
# SERVER LOGIC
# ============================================================================

server <- function(input, output, session) {

  # Select all / Deselect all for Attack Vectors
  observeEvent(input$select_all_actions, {
    updateCheckboxGroupInput(session, "actions",
      selected = c("error", "hacking", "malware", "misuse", "physical", "social")
    )
  })
  observeEvent(input$deselect_all_actions, {
    updateCheckboxGroupInput(session, "actions", selected = character(0))
  })

  # Select all / Deselect all for Threat Actors
  observeEvent(input$select_all_actors, {
    updateCheckboxGroupInput(session, "actors",
      selected = c("external", "internal", "partner")
    )
  })
  observeEvent(input$deselect_all_actors, {
    updateCheckboxGroupInput(session, "actors", selected = character(0))
  })

  # Reactive filtered dataset
  filtered_data <- reactive({

    data <- vcdb_data

    # Filter by region (countries stored as boolean columns: victim.country.XX)
    if (input$region != "all") {
      # Get all country columns that exist in the data
      all_country_cols <- names(data)[str_detect(names(data), "^victim\\.country\\.")]

      if (input$region == "us") {
        # Filter for US: victim.country.US == TRUE
        target_cols <- intersect(us_patterns, all_country_cols)
        if (length(target_cols) > 0) {
          data <- data %>% filter(if_any(all_of(target_cols), ~. == TRUE))
        }
      } else if (input$region == "europe") {
        # Filter for Europe
        target_cols <- intersect(europe_patterns, all_country_cols)
        if (length(target_cols) > 0) {
          data <- data %>% filter(if_any(all_of(target_cols), ~. == TRUE))
        }
      } else if (input$region == "apac") {
        # Filter for Asia-Pacific
        target_cols <- intersect(apac_patterns, all_country_cols)
        if (length(target_cols) > 0) {
          data <- data %>% filter(if_any(all_of(target_cols), ~. == TRUE))
        }
      } else if (input$region == "other") {
        # Filter for countries NOT in US, Europe, or APAC
        known_patterns <- c(us_patterns, europe_patterns, apac_patterns)
        known_cols <- intersect(known_patterns, all_country_cols)
        other_cols <- setdiff(all_country_cols, known_cols)
        if (length(other_cols) > 0) {
          data <- data %>% filter(if_any(all_of(other_cols), ~. == TRUE))
        }
      }
    }

    # Filter by sector
    if (input$sector != "all") {
      if (input$sector == "other") {
        main_sectors <- c("62", "92", "52", "51", "44", "45", "54", "31", "32", "33", "61", "72", "48", "49")
        data <- data %>%
          filter(!str_starts(as.character(victim.industry), paste(main_sectors, collapse = "|")))
      } else {
        data <- data %>%
          filter(str_starts(as.character(victim.industry), input$sector))
      }
    }

    # Filter by year range
    data <- data %>%
      filter(timeline.incident.year >= input$years[1],
             timeline.incident.year <= input$years[2])

    # Filter by action types (keep rows matching ANY selected action)
    if (length(input$actions) > 0 && length(input$actions) < 6) {
      action_filter <- rep(FALSE, nrow(data))
      for (action in input$actions) {
        action_filter <- action_filter | has_any_true(data, paste0("action.", action))
      }
      data <- data[action_filter, ]
    }

    # Filter by actor types (keep rows matching ANY selected actor)
    if (length(input$actors) > 0 && length(input$actors) < 3) {
      actor_filter <- rep(FALSE, nrow(data))
      for (actor in input$actors) {
        actor_filter <- actor_filter | has_any_true(data, paste0("actor.", actor))
      }
      data <- data[actor_filter, ]
    }

    data
  })

  # Summary statistics
  output$summary_stats <- renderUI({
    data <- filtered_data()

    n_incidents <- nrow(data)

    # Best effort organization count
    n_orgs <- data %>%
      filter(!is.na(victim.victim_id) & victim.victim_id != "") %>%
      distinct(victim.victim_id) %>%
      nrow()

    n_breaches <- sum(data$attribute.confidentiality.data_disclosure.Yes, na.rm = TRUE)
    breach_rate <- if (n_incidents > 0) round(n_breaches / n_incidents * 100, 1) else 0

    HTML(paste0(
      "<div style='font-size: 16px;'>",
      "<strong>Approximately ", format(n_orgs, big.mark = ","), " organizations</strong> | ",
      "<strong>", format(n_incidents, big.mark = ","), " incidents</strong><br>",
      "<strong>", format(n_breaches, big.mark = ","), " confirmed breaches</strong> (",
      breach_rate, "% breach rate)",
      "</div>",
      "<div style='font-size: 12px; font-style: italic; color: #666; margin-top: 8px;'>",
      "Incidents may involve multiple attack types or actors. Totals reflect incidents matching any selected filter.",
      "</div>"
    ))
  })

  # Year trend chart
  output$year_chart <- renderPlot({
    data <- filtered_data()

    if (nrow(data) == 0) {
      return(NULL)
    }

    year_data <- data %>%
      group_by(timeline.incident.year) %>%
      summarise(
        Breach = sum(attribute.confidentiality.data_disclosure.Yes, na.rm = TRUE),
        `Incident Only` = n() - sum(attribute.confidentiality.data_disclosure.Yes, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      pivot_longer(cols = c(Breach, `Incident Only`), names_to = "type", values_to = "count")

    ggplot(year_data, aes(x = timeline.incident.year, y = count, fill = type)) +
      geom_bar(stat = "identity", position = "stack") +
      scale_fill_manual(values = c("Breach" = "#d62728", "Incident Only" = "#1f77b4")) +
      scale_x_continuous(breaks = seq(2005, 2021, 2)) +
      labs(x = "Year", y = "Count", fill = "") +
      theme_minimal() +
      theme(
        legend.position = "bottom",
        panel.grid.minor = element_blank()
      )
  })

  # Attack types chart - only show selected action types
  output$action_chart <- renderPlot({
    data <- filtered_data()

    if (nrow(data) == 0 || length(input$actions) == 0) {
      return(NULL)
    }

    # Mapping from checkbox values to display names
    action_mapping <- c(
      "hacking" = "Hacking",
      "malware" = "Malware",
      "social" = "Social",
      "misuse" = "Misuse",
      "physical" = "Physical",
      "error" = "Error"
    )

    # Only count selected action types
    action_counts <- data.frame(
      Action = character(),
      Count = numeric(),
      stringsAsFactors = FALSE
    )

    for (action in input$actions) {
      count <- count_any_true(data, paste0("action.", action))
      action_counts <- rbind(action_counts, data.frame(
        Action = action_mapping[action],
        Count = count,
        stringsAsFactors = FALSE
      ))
    }

    action_counts <- action_counts %>%
      filter(Count > 0) %>%
      arrange(desc(Count))

    if (nrow(action_counts) == 0) {
      return(NULL)
    }

    ggplot(action_counts, aes(x = reorder(Action, Count), y = Count)) +
      geom_bar(stat = "identity", fill = "#2ca02c") +
      coord_flip() +
      labs(x = "", y = "Count") +
      theme_minimal() +
      theme(panel.grid.minor = element_blank())
  })

  # Actor types chart - only show selected actor types
  output$actor_chart <- renderPlot({
    data <- filtered_data()

    if (nrow(data) == 0 || length(input$actors) == 0) {
      return(NULL)
    }

    # Mapping from checkbox values to display names
    actor_mapping <- c(
      "external" = "External",
      "internal" = "Internal",
      "partner" = "Partner"
    )

    # Only count selected actor types
    actor_counts <- data.frame(
      Actor = character(),
      Count = numeric(),
      stringsAsFactors = FALSE
    )

    for (actor in input$actors) {
      count <- count_any_true(data, paste0("actor.", actor))
      actor_counts <- rbind(actor_counts, data.frame(
        Actor = actor_mapping[actor],
        Count = count,
        stringsAsFactors = FALSE
      ))
    }

    actor_counts <- actor_counts %>%
      filter(Count > 0) %>%
      arrange(desc(Count))

    if (nrow(actor_counts) == 0) {
      return(NULL)
    }

    ggplot(actor_counts, aes(x = reorder(Actor, Count), y = Count)) +
      geom_bar(stat = "identity", fill = "#9467bd") +
      coord_flip() +
      labs(x = "", y = "Count") +
      theme_minimal() +
      theme(panel.grid.minor = element_blank())
  })

  # Data types table
  output$data_types_table <- renderDT({
    data <- filtered_data()

    if (nrow(data) == 0) {
      return(NULL)
    }

    # Get data type columns
    data_cols <- names(data)[str_detect(names(data), "^attribute\\.confidentiality\\.data\\.variety\\.")]

    if (length(data_cols) == 0) {
      return(data.frame(Message = "No data type information available"))
    }

    data_type_counts <- data %>%
      select(all_of(data_cols)) %>%
      summarise(across(everything(), ~sum(. == TRUE, na.rm = TRUE))) %>%
      pivot_longer(everything(), names_to = "data_type", values_to = "count") %>%
      filter(count > 0) %>%
      mutate(data_type = str_remove(data_type, "attribute\\.confidentiality\\.data\\.variety\\.")) %>%
      arrange(desc(count)) %>%
      head(10)

    colnames(data_type_counts) <- c("Data Type", "Incidents")

    datatable(
      data_type_counts,
      options = list(
        pageLength = 10,
        searching = FALSE,
        lengthChange = FALSE,
        info = FALSE
      ),
      rownames = FALSE
    )
  })
}

# ============================================================================
# RUN APPLICATION
# ============================================================================

shinyApp(ui = ui, server = server)
