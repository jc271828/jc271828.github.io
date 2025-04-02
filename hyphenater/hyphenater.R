
# load libs ---------------------------------------------------------------

library(shiny)
library(stringr)


# define a function to hyphenate words ------------------------------------

# Consider the situation of multiple spaces between words
hyphenate_text <- function(text) {
  temp <- text %>% str_split(" ") %>% unlist()
  temp <- temp[nchar(temp) > 0]
  return(paste(temp, collapse = "-"))
}


# UI ----------------------------------------------------------------------

ui <- fluidPage(
  titlePanel(title = "Give me some words to hyphenate. Optional: convert everything to lower case.",
             windowTitle = "hyphenater"),
  sidebarLayout(
    mainPanel(
      textInput("input_text", "", placeholder = "Hyphenater is    really ReAlY GREAT"),
      actionButton("hyphenate", "Hyphenate!"),
      actionButton("convert_lower", "Convert to lower case and hyphenate!")
    ),
    mainPanel(
      h3("Result:"),
      verbatimTextOutput("result_text")
    )
  )
)


# sever logic -------------------------------------------------------------

server <- function(input, output, session) {
  
  # A reactive value to store the result text
  result <- reactiveVal("")
  
  # When the Hyphenate! button is clicked
  observeEvent(input$hyphenate, {
    result(hyphenate_text(input$input_text))
  })
  
  # When the Convert to lower case and hyphenate! button is clicked
  observeEvent(input$convert_lower, {
    lower_text <- tolower(input$input_text)
    result(hyphenate_text(lower_text))
  })
  
  output$result_text <- renderText({
    result()
  })
}


# run app -----------------------------------------------------------------

shinyApp(ui, server)




