
library("apitools")
library("btools")
library("dplyr")

system.time(df <- z1())
ht(df)
memory()
# make the file smaller and easier to work with
fof <- df %>% mutate(description=factor(description),
                      freq=factor(freq),
                      variable=factor(variable),
                      date=as.Date(date)) %>%
  filter(!is.na(value))
glimpse(fof)
max(fof$date)
# count(fof, freq)
# count(fof, is.na(value))


devtools::use_data(fof, overwrite=TRUE)

