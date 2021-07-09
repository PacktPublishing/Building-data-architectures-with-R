########################
### C2
# Author: Tomaz Kastrun
#######################


# Data frame

vec1 <- c(29,20,25,28)
vec2 <- c("Tom","Jan","Pet","Jim")
vec3 <- c(3.1, 5.1, 6.3, 3.9)

df <- data.frame(vec1, vec2, vec3)

#show data.frame
head(df)

#check data types and transformations from vector to data.frame
str(df)


#Getting a single observation with all three attributes
df[1,]


############################
#
# Relational vs. non-relational
#
############################


#install.packages("DBI")

library(DBI)

# Connect to the MySQL database: con
con <- dbConnect(RMySQL::MySQL(), 
                 dbname = "dbCustomers", 
                 host = "localhost", 
                 port = 3306,
                 user = "bookSample",
                 password = "Pa$$w0rd")

# Get the list of all the tables available
df_tableNames <- dbListTables(con)

# Get a particular table
df_customerTable <- dbReadTable(con, "tbl_Customer")



# install.packages("RODBC", dependencies=TRUE)
library(RODBC)

# create env for storing the variables/data frames between the functions
assign("getREnvironment", new.env(), envir = .GlobalEnv)


# Function to read data from SQL Server
getSQLServerData <- function()
{
  #extract environment settings for storing data
  getREnvironment <- get("getREnvironment", envir = .GlobalEnv, mode = "environment")
  #get the SQL Server data
  con <- odbcDriverConnect('driver={SQL Server};
                         server=localhost;
                         database=dbCustomers;trusted_connection=true')
  db_df <- sqlQuery(con, 'SELECT 
                         *
                          FROM tbl_Customer ORDER BY id DESC')
  close(con)
  #overwrite existing data with new data
  df_overwrite <- db_df
  getREnvironment$db_df <- data.frame(df_overwrite)
  try(assign("getREnvironment", getREnvironment, envir = .GlobalEnv))
  invisible() #do not print the results
}

# Get the results of the data.frame
getREnvironment$db_df



#install.packages("sqldf")
# load sqldf into workspace
library(sqldf)

# use SQL syntax to get the results from data.frame
sqldf("select * from cdf")
sqldf("select avg(val) AS avg_age from cdf") 


new <- sqldf("select 10 as val,'Tom' as name,'Q' as lett") 

#sqldf("insert into cdf(val,name, lett)  values ('Tom',10,'Q')")
cdf <- sqldf(c("insert into cdf select * From new", "select * From cdf"))

#Check the data frame
cdf



# neo4j R
# remotes::install_github("neo4j-rstats/neo4r")
# install.packages("neo4r")

library(neo4r)
 
con <- neo4j_api$new(
  url = "http://localhost:7474",
  user = "neo4j", 
  password = "password"
)

# Ping
con$ping()


# Note that play_movies is only available for versions >= 0.1.3 
play_movies() %>%
  call_neo4j(con)



# Neo4jShell

#install.packages("neo4jshell")
library(neo4jshell)

# set credentials (no port required in bolt address)
neo_movies <- list(address = "localhost", uid = "neo4j", pwd = "Pa$$w0rd")

# find directors of movies with Kevin Bacon as actor
CQL <- 'MATCH (p1:Person {name: "Kevin Bacon"})-[:ACTED_IN]->(m:Movie)<-[:DIRECTED]-(p2:Person)
RETURN p2.name, m.title;'

# run query
neo4j_query(con = neo_movies, qry = CQL)
