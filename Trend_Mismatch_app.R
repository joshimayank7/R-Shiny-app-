library(shiny)
library(sqldf)
##_______________________________________
### Sourcing functions required for processing

temp_path <- "E:\\R_Process\\R_Intermediate Files\\TREND_REPORT_WV\\Function_TM"
setwd(temp_path)
list_of_functions <<- list.files(temp_path,pattern="*.R",recursive = T)
invisible(sapply(list_of_functions,source,.GlobalEnv))

##________________________________________

mydb <- dbConnect(RSQLite::SQLite(), paste0("E:\\R_Process\\R_Control Files\\DataIngestion.db"))
country_subcat_all <<- dbGetQuery(mydb,'SELECT * FROM Country_Subcategory_All') 
dbDisconnect(mydb)

country_subcat_all$Subcategory[is.na(country_subcat_all$Subcategory)] <- ""

for (i in 1:nrow(country_subcat_all)){
  print(i)
  if (country_subcat_all$Subcategory[i] == ""){
    country_subcat_all$Subcategory[i] <- country_subcat_all$Product_Category[i]
  }
}
country_subcat_all<- country_subcat_all[,c(3,6)]

##________________________________________ UI _______________________________________

my_app <- shinyApp(
  ui <- fluidPage(
  ## App title
  titlePanel( "TREND MISMATCH",windowTitle = "TREND MISMATCH"),
  sidebarPanel(
    selectInput(inputId = "Country", label = "Country", choices = sort(c("",country_subcat_all$Country)),selected = "",multiple = FALSE)
    ,uiOutput("Subcategory"),
    actionButton("runButton","RUN")
  )
  
),

##________________________________________ SERVER _______________________________________

server <- function(input, output) {
  observeEvent(input$Country,{
    if(input$Country == ""){
      output$Subcategory <- renderUI({
        selectInput(inputId = "Subcategory", label = "Subcategory", choices = sort(c("",unique(country_subcat_all$Subcategory))), selected = "",multiple = FALSE)
      })
    }else{
      subcatlist <- sort(unique(subset(country_subcat_all,country_subcat_all$Country == input$Country)$Subcategory))
      output$Subcategory  <- renderUI(
        selectInput(inputId = "Subcategory",label = "Subcategory", choices = subcatlist, selected = "")
      )
    }
  })
  
  observeEvent(input$runButton,{
    # browser()
    ##trend_mis is the function which performs action using the input variables
    trend_mis(input$Country,input$Subcategory)
  })
})

# shinyApp(ui = ui, server = server)

runApp(my_app, launch.browser = TRUE)





