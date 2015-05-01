
library(apitools)
library(btools)
library(dplyr)

df <- z1()
ht(df)
memory()
# make the file smaller and easier to work with
fz1 <- df %>% mutate(description=factor(description),
                      freq=factor(freq),
                      variable=factor(variable),
                      date=as.Date(date)) %>%
  filter(!is.na(value))
glimpse(fz1)
# count(fof, freq)
# count(fof, is.na(value))

devtools::use_data(fz1, overwrite=TRUE)

