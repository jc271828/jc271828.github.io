
# load lib ----------------------------------------------------------------

library(shiny)
library(readxl)
library(magrittr)


# load df -----------------------------------------------------------------

words <- read_xlsx("df.xlsx") %>% as.data.frame()


# define UI ---------------------------------------------------------------

ui <- fluidPage(
  # Add custom CSS in the head
  tags$head(
    tags$style(HTML("
      /* Increase font size for text outputs */
      .large-text { font-size: 2em; }
      
      /* Center the content in the main panel */
      .center-content { text-align: center; }
      
      /* Flex container for the Romanization header and button */
      .roman-container {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 20px;
      }
      
      /* Increase the font size and padding for buttons */
      .action-button {
         font-size: 2em;
         padding: 5px 5px;
      }
      
      /* Center the bottom button */
      .bottom-button {
         font-size: 3em;
         padding: 5px 5px;
         margin-top: 30px;
         display: block;
         margin-left: auto;
         margin-right: auto;
      }
    "))
  ),
  
  titlePanel(
    title = "Quiz Yourself: Hangul Pronunciation",
    windowTitle = "Hangul Flashcards"
  ),
  
  # Use a main panel for a centered vertical layout
  mainPanel(
    div(class = "center-content",
        h2("Hangul"),
        tags$span(class = "large-text", textOutput("hangulOut")),
        br(), br(), # inserts two line breaks
        
        h2("English"),
        tags$span(class = "large-text", textOutput("englishOut")),
        br(), br(),
        
        # Flex container for the Romanization header and Reveal button
        div(class = "roman-container",
            h3("Romanization"),
            actionButton("reveal", "Reveal", class = "action-button")
        ),
        tags$span(class = "large-text", textOutput("romanOut")),
        br(), br(),
        
        # Place the "Test me another one!" button in its own container so it is centered
        actionButton("newWord", "Test me another one!", class = "bottom-button")
    )
  )
)

server <- function(input, output, session) {
  
  # Reactive values store the current word and whether romanization is revealed.
  current <- reactiveValues(
    hangul  = "",
    english = "",
    roman   = "",
    showRoman = FALSE
  )
  
  # Function to get a new random word from the data frame.
  newWord <- function() {
    idx <- sample(1:nrow(words), 1)
    current$hangul  <- words$hangul[idx]
    current$english <- words$english[idx]
    current$roman   <- words$roman[idx]
    current$showRoman <- FALSE
  }
  
  # Generate an initial random word when the app starts.
  newWord()
  
  # When the "Test me another one!" button is clicked, get a new word.
  observeEvent(input$newWord, {
    newWord()
  })
  
  # When the "Reveal romanization" button is clicked, show the romanization.
  observeEvent(input$reveal, {
    current$showRoman <- TRUE
  })
  
  # Display outputs:
  output$hangulOut <- renderText({
    current$hangul
  })
  
  output$englishOut <- renderText({
    current$english
  })
  
  output$romanOut <- renderText({
    if (current$showRoman) current$roman else ""
  })
  
}

shinyApp(ui, server)
