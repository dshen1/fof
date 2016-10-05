
# 10/5/2016

#****************************************************************************************************
#                Libraries and global functions ####
#****************************************************************************************************
library("magrittr")
library("plyr") # needed for ldply; must be loaded BEFORE dplyr
library("tidyverse")
options(tibble.print_max = 60, tibble.print_min = 60) # if more than 60 rows, print 60 - enough for states
# ggplot2 tibble tidyr readr purrr dplyr


library("hms") # hms, for times.
library("stringr") # stringr, for strings.
library("lubridate") # lubridate, for date/times.
library("forcats") # forcats, for factors.
library("readxl") # readxl, for .xls and .xlsx files.
library("btools")

safe.ifelse <- function(cond, yes, no) {
  # so dates don't lose their class!
  structure(ifelse(cond, yes, no), class = class(yes))
}


#****************************************************************************************************
#                Download Flow of Funds data ####
#****************************************************************************************************
fget <- "https://www.federalreserve.gov/releases/z1/Current/z1_csv_files.zip"
zfn <- "z1_csv_files.zip"

temp <- tempfile()
download.file(fget, temp, mode="wb")

lfiles <- unzip(temp, list=TRUE) # data frame of files in the zip archive
csvfiles <- str_subset(lfiles$Name, "csv/")
ddfiles <- str_subset(lfiles$Name, "data_dictionary/")


#****************************************************************************************************
#                first get the csv files ####
#****************************************************************************************************
fcsv <- function(fn) {
  print(fn)
  tmp <- read_csv(unz(temp, fn))
  if(str_detect(tmp$date[1], "Q")) freq <- "Q" else
    freq <- "A"
  tmp <- tmp %>% mutate(src=str_sub(fn, 5, -5), date=as.character(date), freq=freq)
  tmpl <- tmp %>% gather(variable, value, -date, -freq, -src) %>%
    mutate(value=cton(value))
  # some files have 4 versions of the same data, all with same numbers
  # gather puts _1, _2, _3, _4 on variable
  # get unique values
  tmplu <- tmpl %>% mutate(variable=ifelse(str_detect(variable, "_"), str_sub(variable, 1, -3), variable)) %>%
    unique
  return(tmplu)
}
csvdf <- ldply(csvfiles, fcsv, .progress="text") %>% as_tibble()

csvdf2 <- csvdf %>% mutate(olddate=date,
                     date=as.Date(parse_date_time(date, orders = "Yq")),
                     date=safe.ifelse(freq=="A", as.Date(paste0(olddate, "-01-01")), date)) %>%
  select(-olddate)

# quick check to be sure we only have Q and A
csvdf2 %>% mutate(l2=str_sub(variable, -2, -1)) %>%
  group_by(freq, l2) %>%
  summarise(n=n())

csvdf3 <- csvdf2 %>% mutate(variable=str_sub(variable, 1, -3),
                            year=as.integer(year(date))) %>%
  filter(!is.na(value))
csvdf3


#****************************************************************************************************
#                now the data dictionary files ####
#****************************************************************************************************
fdd <- function(fn) {
  print(fn)
  cnames <- c("variable", "description", "lineno", "table", "units")
  tmp <- read_tsv(unz(temp, fn), col_names=cnames)
  tmp <- tmp %>% mutate(src=str_sub(fn, 17, -5),
                        variable=str_sub(variable, 1, -3))
  return(tmp)
}

dd.df <- ldply(ddfiles, fdd, .progress="text") %>% as_tibble()

dd.df2 <- dd.df %>% arrange(lineno) %>%
  group_by(src, variable) %>%
  slice(1) # get rid of dups


#****************************************************************************************************
#                create fof file and save ####
#****************************************************************************************************
fof <- csvdf3 %>% left_join(dd.df2) %>%
  mutate_at(vars(src, description, freq, variable, description, lineno, table, units), factor) %>%
  select(date, year, freq, variable, value, src, lineno, description, table, units)
glimpse(fof)


max(fof$date)
# count(fof, freq)
# count(fof, is.na(value))

devtools::use_data(fof, overwrite=TRUE)


#****************************************************************************************************
#                CAUTION: ONLY unlink when all done, or file will have to be re-downloaded ####
#****************************************************************************************************
unlink(temp)

