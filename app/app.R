library(shiny)
library(shinydashboard)
library(httr)
library(globals)
library(future)

source("analysis.R")
source("plot_exception.R")

size = 450

ui<-dashboardPage(
  dashboardHeader(title = "Rheumatoid Arthritis"),
  dashboardSidebar(selectInput(inputId = "Comparison",
                             label = "Differential Comparisons",
                             choices = list(`Naive` = list("RA vs Healthy (Naive)"="Naive_RAvsHC"),
                                            `Central Memory` = list("RA vs Healthy (CM)"="CM_RAvsHC"),
                                            `Effector Memory` = list("RA vs Healthy (EM)"="EM_RAvsHC"))
                             ),
                   textInput(inputId = "Gene",
                             label = "Gene Symbol",
                             value = "STAT1"),
                   sliderInput(inputId = "Flank",
                               label = "Zoom",
                               min = 0,max = 50000,
                               value = 10000,step = 10000,
                               pre = "x", sep = ",",
                               animate = F)
                   # ,actionButton(inputId = "neg10K", label = "< 10k")
                   # ,actionButton(inputId = "pos10K", label = "> 10k")
  ),
  dashboardBody(
    fluidRow(
    box(title = "MA Plot",
    # the MA-plot
    plotOutput("plotma", click="plotma_click"),# width=size, height=size),
    collapsible = TRUE),
    box(title = "Normalized Counts",
    # # the counts plot for a single gene
    plotOutput("plotcounts"),# width=size, height=size),
    #
      collapsible = TRUE,
    )
  ),
  fluidRow(box(width = 12,
    tableOutput(outputId = 'clickedPoints')
  )
  ),
  # fluidRow(box(width = 12,
  #              tableOutput(outputId = 'hover_info')
  # )
  # ),
  fluidRow(box(width = 12,
    plotOutput(outputId = "Track")
  )
  )
  )
)

server<-function(input,output,session){

  # observeEvent(input$neg10K,{
  #   print(as.numeric(input$neg10K))
  # })
  # 
  # observeEvent(input$pos10K,{
  #   print(as.numeric(input$pos10K))
  # })
  
  # MA-plot of all genes
  output$plotma     <-  renderPlot({
    comparison <- input$Comparison
    ymax <- 8
    xloc <- 6 # px
    yloc <- 6 # py
    tops <- read.table(paste0(File_location,"/WebInputFiles/RA/",comparison,".txt"),header = T)
    tops$Significance<-"NA"
    if((comparison == "tcx0.01vsbaselineEach") || (comparison == "tcx1vsbaselineEach")){
      ymax <- 4
      tops[tops$adj.P.Val <= 0.001,"Significance"]<-"< 0.001"
      tops[tops$adj.P.Val > 0.001,"Significance"]<-"> 0.001"
      tops_sig<-subset(tops,adj.P.Val<0.001)
      tops_sig_up<-subset(tops_sig,logFC>0)
      tops_sig_down<-subset(tops_sig,logFC < 0)
      tops_not_sig<-subset(tops,adj.P.Val>=0.001)
    } else {
      ymax <- 4
      tops[tops$adj.P.Val <= 0.05,"Significance"]<-"< 0.05"
      tops[tops$adj.P.Val > 0.05,"Significance"]<-"> 0.05"
      tops_sig<-subset(tops,adj.P.Val<0.05)
      tops_sig_up<-subset(tops_sig,logFC>0)
      tops_sig_down<-subset(tops_sig,logFC < 0)
      tops_not_sig<-subset(tops,adj.P.Val>=0.05)
    }
    PvsU_up<-tops_sig_up
    PvsU_down<-tops_sig_down
    PvsU_not_sig<-tops_not_sig
    tops_sig_mod<-tops_sig_up
    tops_sig_mod<-rbind(tops_sig_mod,tops_sig_down)
    
    ggplot(tops,aes(x=AveExpr, y=logFC, color=Significance,ymin = -ymax, ymax = ymax)) +
      geom_point() +
      coord_cartesian() +
      ylab("log2 FC") +
      xlab("log2 Normalized Reads") +
      ggtitle(gsub("vs"," vs ",gsub("_"," ",input$Comparison)))
    
  })
  
  #get the clicked points!
  clicked <- reactive({
    comparison <- input$Comparison
    ymax <- 8
    xloc <- 6 # px
    yloc <- 6 # py
    tops <- read.table(paste0(File_location,"/WebInputFiles/RA/",comparison,".txt"),header = T)
    tops$Significance<-"NA"
    if((comparison == "tcx0.01vsbaselineEach") || (comparison == "tcx1vsbaselineEach")){
      tops[tops$adj.P.Val <= 0.001,"Significance"]<-"< 0.001"
      tops[tops$adj.P.Val > 0.001,"Significance"]<-"> 0.001"
    } else {
      tops[tops$adj.P.Val <= 0.05,"Significance"]<-"< 0.05"
      tops[tops$adj.P.Val > 0.05,"Significance"]<-"> 0.05"
    }
    
    # We need to tell it what the x and y variables are:
    nearPoints(tops, input$plotma_click, xvar = "AveExpr", yvar = "logFC")
    # updateTextInput(session, "Gene", value = paste(rownames(clicked()[1,])))
  })
  
  #output those points into a table
  output$clickedPoints <- renderTable({
    if ((nrow(clicked())>0)) clicked()[1,]
  }, rownames = T)
  
  # This will change the value of input$Gene, based on x
  observe({
    if(nrow(clicked())>0){
        updateTextInput(session, "Gene", value = rownames(clicked()[1,]))
    }
  })
  
  # counts plot
  output$plotcounts <-  renderPlot({
    # par(mar=c(5,5,3,2),cex.lab=2,cex.main=2,cex.axis=1.5)
    # plot the counts for the selected gene
    # idx = current$idx
    # if (!is.null(idx)) plotCounts( dds, idx ,"Group")
    tryCatch(
      if ((nrow(clicked())>0)){
        vstNormalizedCounts_RA$Group<-factor(x = vstNormalizedCounts_RA$Group,
                                                               levels = c("HC_NA","HC_CM","HC_EM",
                                                                          "RA_NA","RA_CM","RA_EM"))
        cols_group<-c("palegreen1","palegreen2","palegreen3",
                         "red1","red2","red3")
        ggplot() +
          geom_point(data = vstNormalizedCounts_RA[vstNormalizedCounts_RA$Peaks %in% input$Gene,],
                     aes(x=Group, y=vstNormalizedCounts, color = Group )) +
          scale_color_manual(values= cols_group) + theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
          ggtitle(input$Gene)
      }
      else{
        textOutput("Please select a region in MA plot")
      },
      error=function(e) e
    )
  })
  
  output$hover_info <- renderTable({
    if(!is.null(input$plotcounts)){
      hover=input$plotcounts
      dist=sqrt((hover$x-vstNormalizedCounts_Macrophage$Group)^2+(hover$y-vstNormalizedCounts_Macrophage$vstNormalizedCounts)^2)
      cat("SampleID: \n")
      if(min(dist) < 3)
        vstNormalizedCounts_Macrophage$SampleID[which.min(dist)]
    }
  })
  
  output$Track      <-  renderPlot({
    if((grepl(":", input$Gene)==F) && (input$Gene %notin% UCSC.hg19.genes$V1)){
      return(plot_exception("Please enter a valid Gene Symbol or region."))
    } else {
      # showModal(modalDialog("Loading Tracks", footer=NULL))
      tryCatch({
        Track_list<-list(
          RA_EM = paste0(File_location,"/Tracks/rheumatoid_arthritis/","RA_EM_Average.bw"),
          RA_CM = paste0(File_location,"/Tracks/rheumatoid_arthritis/","RA_CM_Average.bw"),
          RA_Naive = paste0(File_location,"/Tracks/rheumatoid_arthritis/","RA_NA_Average.bw"),
          Healthy_EM = paste0(File_location,"/Tracks/rheumatoid_arthritis/","Healthy_EM_Average.bw"),
          Healthy_CM = paste0(File_location,"/Tracks/rheumatoid_arthritis/","Healthy_CM_Average.bw"),
          Healthy_Naive = paste0(File_location,"/Tracks/rheumatoid_arthritis/","Healthy_Naive_Average.bw")
          )
        
        Track_cols<-c("red3","red2","red1","palegreen3","palegreen2","palegreen1")
        
        url <- "https://atac-tracks-api-e2gbey6dba-uw.a.run.app"
        
        body <- list(
          distflank = input$Flank,
          Genes = input$Gene,
          Track_list = Track_list,
          Track_cols = Track_cols
        )
        
        path <- 'atacTracks'
        
        raw.result %<-% POST(url = url, path = path, body = body, encode = 'json')
        
        apiIn %<-% base::unserialize(httr::content(raw.result))
        
        numTracks<-length(Track_list)
        numAll<-length(names(apiIn$tracks))
        j=1
        for(i in ((numAll-numTracks)+1):numAll){
          names(apiIn$tracks)[i]<-gsub("_","-",names(apiIn$tracks)[i])
          names(apiIn$tracks)[i]<-paste0("\t",names(apiIn$tracks)[i])
          setTrackStyleParam(apiIn$tracks[[i]], "ylabpos", "bottomleft")
          setTrackStyleParam(apiIn$tracks[[i]], "ylabgp", list(cex=1, col=Track_cols[j]))
          j=j+1
        }
        
        vp %<-% viewTracks(apiIn$tracks, gr=apiIn$geneRegion, viewerStyle=apiIn$view)
      }, warning = function(war) {
        
        # warning handler picks up where error was generated
        message("Tracks could not be loaded!")
        
      }, error = function(err) {
        message("Tracks could not be loaded!")
        
      }
      )
      # removeModal()
    }
  })
}

shinyApp(ui = ui,server = server)