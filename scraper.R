library('rvest')
library('tidyverse')
library('data.table')
library('pbapply')

url <- 'https://www.imdb.com/chart/top'
webpage <- read_html(url)
my_links <- 
  paste0('https://www.imdb.com',
         webpage %>%
           html_nodes('.titleColumn a')%>%
           html_attr('href')
  )

imdb_info_getter <- function(film_url) {
  film_webpage <- read_html(film_url)
  storyline <- film_webpage %>%
    html_nodes('#titleStoryLine p span')%>%
    html_text()
  
  title <- film_webpage %>%
    html_nodes('#ratingWidget strong')%>%
    html_text()
  
  rating <- film_webpage %>%
    html_nodes('strong span') %>%
    html_text
  
  n_reviews <- film_webpage %>%
    html_nodes('.imdbRating a') %>%
    html_text
  
  director <- film_webpage %>%
    html_nodes('.summary_text+ .credit_summary_item a') %>%
    html_text
  
  summary <- film_webpage %>%
    html_nodes('.summary_text') %>%
    html_text
  
  return(data.frame('storyline'= storyline, 
                    'title'= title, 
                    'rating'= rating, 
                    'n_reviews'= n_reviews, 
                    'director'= director,
                    'summary' = summary))
}
df <- pblapply(my_links, imdb_info_getter)
df <- rbindlist(df)

# No idea how, but I have some duplications.
df <- subset(df, !duplicated(subset(df, select=c(title))))


write_csv(df, "imdb_top_250.csv")
saveRDS(df, "imdb_top_250.rds")
