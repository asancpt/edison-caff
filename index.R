#!/SYSTEM/R/3.3.2/bin/Rscript

# setup ----

source("R/function.R")

localLibPath <- c("./lib", .libPaths())
if (Get_os() == 'linux') .libPaths(localLibPath)
.libPaths()

library(caffsim) # devtools::install_github('asancpt/caffsim')

edisonlib <- c("tidyverse", "mgcv", "psych", "markdown", "knitr")
lapply(edisonlib, function(pkg) {
  if (system.file(package = pkg) == '') install.packages(pkg)
})
lapply(edisonlib, library, character.only = TRUE) # if needed # install.packages(mylib, lib = localLibPath)

if (length(intersect(dir(), "result")) == 0) system("mkdir result")

Args <- commandArgs(trailingOnly = TRUE) # SKIP THIS LINE IN R if you're testing!
if (identical(Args, character(0))) Args <- c("-inp", "data-raw/input.deck")
if (Args[1] == "-inp") InputParameter <- Args[2] # InputPara.inp

inputInit <- read.table(InputParameter, row.names = 1, sep = "=",  comment.char = ";",
                        strip.white = TRUE, stringsAsFactors = FALSE)

input <- as_tibble(t(inputInit)) %>%
  mutate_at(vars(concBWT, concDose, concNum, superTau, superRepeat), as.numeric) %>% 
  mutate_at(vars(Log), as.logical)

inputSummary <- as_tibble(inputInit) %>%
  mutate(Input = c("Body Weight", "Caffeine Dose", "Simulation Subject N", "Log Y-axis", "Plot Format", 
                   "Multiple Dosing Interval", "Multiple Dosing")) %>% 
  mutate(Unit = c("kg", "mg", "", "", "", "hour", "times")) %>% 
  select(Input, Value = 1, Unit)

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

ggsave(ifelse(Get_os() != "linux", "result/Plot_Cmax.jpg", "result/Plot_Cmax.pdf"), 
       output$plot, width = 8, height = 4.5)

# Plot_AUC ----------------------------------------------------------------

p <- ggplot(ggDset, aes(x=factor(BWT), y=AUC, colour=AUC)) +
  xlab("Body Weight (kg)") + ylab("AUC (mg*hr/L)") + theme_linedraw()

if (input$pformat == "Sina") output$aucplot <- (p + geom_sina(binwidth = 4))
if (input$pformat == "Jitter") output$aucplot <- (p + geom_jitter(position = position_jitter(width = .1)))
if (input$pformat == "Point") output$aucplot <- (p + geom_point())
if (input$pformat == "Boxplot") output$aucplot <- (p + geom_boxplot())

ggsave(ifelse(Get_os() != "linux", "result/Plot_AUC.jpg", "result/Plot_AUC.pdf"), 
       output$aucplot, width = 8, height = 4.5)

# Single PK ---------------------------------------------------------------

#set.seed(Seed)
SingleDataset <- caffDataset(input$concBWT, input$concDose, input$concNum)

write.csv(SingleDataset, "result/Data_SingleDose.csv", row.names = FALSE)
write.csv(DescribeDataset(SingleDataset), "result/Data_SingleDosePK.csv", row.names = FALSE)

output$concplot <- caffPlot(caffConcTime(input$concBWT, input$concDose, input$concNum))

ggsave(ifelse(Get_os() != "linux", "result/Plot_SingleDose.jpg", "result/Plot_SingleDose.pdf"), 
       output$concplot, width = 8, height = 4.5)

# Multiple PK -------------------------------------------------------------

#set.seed(Seed)
MultipleDataset <- caffDatasetMulti(input$concBWT, input$concDose, input$concNum, input$superTau)

write.csv(MultipleDataset, "result/Data_MultipleDose.csv", row.names = FALSE)
write.csv(DescribeDataset(MultipleDataset), "result/Data_MultipleDosePK.csv", row.names = FALSE)

p <- caffPlotMulti(caffConcTimeMulti(input$concBWT, input$concDose, input$concNum, input$superTau, input$superRepeat))

if (input$Log == FALSE) output$superplot <- (p) else 
  output$superplot <- (p + scale_y_log10()) #limits = c(0.1, max(80, ggsuper$Conc))))

ggsave(ifelse(Get_os() != "linux", "result/Plot_MultipleDose.jpg", "result/Plot_MultipleDose.pdf"), 
       output$superplot, width = 8, height = 4.5)

# Modification ------------------------------------------------------------

if (Get_os() != "linux") {
} else {
  system('convert -density 300 "result/Plot_Cmax.pdf" result/Plot_Cmax.jpg')
  system('convert -density 300 "result/Plot_AUC.pdf" result/Plot_AUC.jpg')
  system('convert -density 300 "result/Plot_SingleDose.pdf" result/Plot_SingleDose.jpg')
  system('convert -density 300 "result/Plot_MultipleDose.pdf" result/Plot_MultipleDose.jpg')
}

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
system(ifelse(Get_os() != "linux", "ls result/*.jpg", 'rm result/*.pdf'))
system(paste0('rm ', file_doc, ".md ", file_doc2, ".md"))

# system('cp result/*.jpg ./')
