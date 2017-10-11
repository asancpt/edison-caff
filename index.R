#!/SYSTEM/R/3.3.3/bin/Rscript

# setup ----

source("R/function.R")
options(bitmapType='cairo')

if (grepl('linux', R.version$os)) .libPaths(c("./lib", .libPaths()))
print('libPaths() modified')
print(.libPaths())

library(caffsim) # devtools::install_github('asancpt/caffsim')
library(ggplot2)
library(dplyr)
library(tidyr)
library(tibble)
library(purrr)
library(readr)
library(markdown)
library(knitr)
library(mgcv)
library(psych)

print(sessionInfo())
print(capabilities())

# make `result` folder if not exists

if (length(intersect(dir(), "result")) == 0) system("mkdir result")

Args <- commandArgs(trailingOnly = TRUE) # SKIP THIS LINE IN R if you're testing!
if (identical(Args, character(0))) Args <- c("-inp", "data-raw/input.deck")
if (Args[1] == "-inp") InputParameter <- Args[2] # InputPara.inp

inputInit <- readr::read_delim(InputParameter, delim = '=', comment = ';', col_names = FALSE, trim_ws = TRUE) 

input <- inputInit %>% 
  spread(X1, X2) %>% 
  mutate_at(vars(concBWT, concDose, concNum, superTau, superRepeat), as.numeric) %>% 
  mutate_at(vars(Log), as.logical)

inputSummary <- inputInit %>%
  mutate(Input = c("Body Weight", "Caffeine Dose", "Simulation Subject N", "Log Y-axis", "Plot Format", 
                   "Multiple Dosing Interval", "Multiple Dosing")) %>% 
  mutate(Unit = c("kg", "mg", "", "", "", "hour", "times")) %>% 
  select(Input, Value = X2, Unit)

write.csv(inputSummary, "result/Data_InputSummary.csv", row.names = FALSE)

output <- list()

#set.seed(Seed)
showdataTable <- round_df(caffDataset(input$concBWT, input$concDose, input$concNum), 2) %>% 
  mutate(SUBJID = row_number()) %>% 
  select(9, 1:8)

output$showdata <- showdataTable

# Plot_Cmax ---------------------------------------------------------------

Rnorm <- c(23, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 84)

ggDset <- lapply(Rnorm, function(x){
  caffDataset(x, input$concDose, input$concNum) %>% 
    select(Tmax, Cmax, AUC, Half_life, CL, V) %>% 
    mutate(BWT = x)
}) %>% bind_rows()

p <- ggplot(ggDset, aes(x=factor(BWT), y=Cmax, colour=Cmax)) +
  xlab("Body Weight (kg)") + ylab("Cmax (mg/L)") +
  geom_hline(yintercept = 80, colour="red") + 
  geom_hline(yintercept = 40, colour="blue") + 
  geom_hline(yintercept = 10, colour="green") +
  scale_colour_gradient(low="navy", high="red", space="Lab") + 
  theme_linedraw()

if (input$pformat == "Sina") output$plot <- (p + geom_sina(binwidth = 3, size = 1))
if (input$pformat == "Jitter") output$plot <- (p + geom_jitter(position = position_jitter(width = .1)))
if (input$pformat == "Point") output$plot <- (p + geom_point())
if (input$pformat == "Boxplot") output$plot <- (p + geom_boxplot())

ggsave("result/Plot_Cmax.jpg", output$plot, width = 8, height = 4.5)

# Plot_AUC ----------------------------------------------------------------

p <- ggplot(ggDset, aes(x=factor(BWT), y=AUC, colour=AUC)) +
  xlab("Body Weight (kg)") + ylab("AUC (mg*hr/L)") + theme_linedraw()

if (input$pformat == "Sina") output$aucplot <- (p + geom_sina(binwidth = 4))
if (input$pformat == "Jitter") output$aucplot <- (p + geom_jitter(position = position_jitter(width = .1)))
if (input$pformat == "Point") output$aucplot <- (p + geom_point())
if (input$pformat == "Boxplot") output$aucplot <- (p + geom_boxplot())

ggsave("result/Plot_AUC.jpg", output$aucplot, width = 8, height = 4.5)

# Single PK ---------------------------------------------------------------

#set.seed(Seed)
SingleDataset <- caffDataset(input$concBWT, input$concDose, input$concNum)

write.csv(SingleDataset, "result/Data_SingleDose.csv", row.names = FALSE)
write.csv(DescribeDataset(SingleDataset), "result/Data_SingleDosePK.csv", row.names = FALSE)

output$concplot <- caffPlot(caffConcTime(input$concBWT, input$concDose, input$concNum))

ggsave("result/Plot_SingleDose.jpg", output$concplot, width = 8, height = 4.5)

# Multiple PK -------------------------------------------------------------

#set.seed(Seed)
MultipleDataset <- caffDatasetMulti(input$concBWT, input$concDose, input$concNum, input$superTau)

write.csv(MultipleDataset, "result/Data_MultipleDose.csv", row.names = FALSE)
write.csv(DescribeDataset(MultipleDataset), "result/Data_MultipleDosePK.csv", row.names = FALSE)

p <- caffPlotMulti(caffConcTimeMulti(input$concBWT, input$concDose, input$concNum, input$superTau, input$superRepeat))

if (input$Log == FALSE) output$superplot <- (p) else 
  output$superplot <- (p + scale_y_log10()) #limits = c(0.1, max(80, ggsuper$Conc))))

ggsave("result/Plot_MultipleDose.jpg", output$superplot, width = 8, height = 4.5)

# Modification ------------------------------------------------------------

# Summary
file_doc <- "documentation"
knit(paste0(file_doc, ".Rmd"), paste0(file_doc, ".md"))
markdownToHTML(paste0(file_doc, ".md"), "result/Report_Summary.html", options = c("toc", "mathjax"))#, stylesheet = "css/my.css")
# browseURL("result/Report_Summary.html")

# Appendix
file_doc2 <- "appendix"
knit(paste0(file_doc2, ".Rmd"), paste0(file_doc2, ".md"))
markdownToHTML(paste0(file_doc2, ".md"), "result/Report_Appendix.html", options = c("toc", "mathjax"))#, stylesheet = "mycss.css")
# browseURL("result/Report_Appendix.html")

# Tidy
system(paste0('rm ', file_doc, ".md ", file_doc2, ".md"))

