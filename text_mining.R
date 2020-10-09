

# Try to use a specific package
# to cluster titles automatically

# This is how you install a new package
# You only need to install this once
# so next time you only run the library(tm)
# and library(proxy) lines
install.packages("tm")
install.packages("proxy")


# Load in the new packages
library(tm)
library(proxy)
library(stringr)
library(tidyverse)

# I just made up a fake list of titles
# that I store in the "test_string" variable
# You can pull this from your dataset
# using the $ convention
# for your dataset that might be df1$title

test_string <- c("Solutions Architect", "Jira Solutions Architect",
                 "Salesforce Solution Architect", "Software Engineer",
                 "Python Engineer", "Industrial Architect")

# Create a word corpus that
# holds all of your titles in a
# special format that works with 
# text clustering package in R
# I usually set all my text to lower case
test_lower <- tolower(test_string)
test_corp <- Corpus(VectorSource(test_lower))
output_string <- DocumentTermMatrix(test_corp)
# Get weighting for how often a word occurs
# in a title, I just picked this kind of weighting
# but there are other options - see 
# https://medium.com/@SAPCAI/text-clustering-with-r-an-introduction-for-data-scientists-c406e7454e76
output_weight <- weightTfIdf(output_string)

# You can use this function to remove terms
# that are rarely present in your text
# a proportion of 0.99 means that words which
# are absent from 99% of entries will be removed
tdm.tfidf <- removeSparseTerms(output_weight, 0.99) 
# Turn these weights into a matrix
tfidf.matrix <- as.matrix(tdm.tfidf) 
# Cosine distance matrix (useful for specific clustering algorithms) 
# according to the tutorial
dist.matrix <- dist(tfidf.matrix, method = "cosine")

# Two ways to cluster
clustering.hierarchical <- hclust(dist.matrix, method = "ward.D2")
# I chose the kmeans clustering
# You need to set the number of output clusters
# manually, that it might take some trial and error
# meaning change "centers = 4" to 20, or 50, depending on
# your application.
clustering.kmeans <- kmeans(tfidf.matrix, centers = 4) 

# This is where I store the output
grouping <- data.frame(group = clustering.kmeans$cluster,
                       test_string = test_lower)

# If you have your loaded dataset
# you can store this grouping information
# in a column, so if your dataframe is named
# df1 then you can execute df1$group <- clustering.kmeans$cluster

# If you want to see what titles are included in your clusters
# you can do it like so
# Just rerun this code with a new group number
# to see what's included
filt_terms <- filter(grouping, group == 2)
# Can use view to look at your groups
View(filt_terms)



##################
# If you want to search for a
# particular term like we were
# trying to do when using grepl
# you can use the "str_detect" function
# from the "stringr" package
# See this cheatsheet for more information
# https://rstudio.com/resources/cheatsheets/
# Look up the work with strings cheatsheet

library(stringr)
# Another way to deal with finding words
# This will give you a list of true and false
# that indicates a match, even if it's only
# a small portion of the word
word_detections <- str_detect(grouping$test_string, "solution" )
# Look at those rows which had solution
grouping$test_string[word_detections]

# You can also filter your data using this solution
filt_data <- filter(grouping, str_detect(test_string, "solution"))



