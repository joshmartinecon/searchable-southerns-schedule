
rm(list = ls())
setwd("C:/Users/jmart/OneDrive/Desktop/GitHub/searchable-southerns-schedule/")
'%ni%' = Negate('%in%')
library(RSelenium)
library(wdman)
library(netstat)
library(rvest)

##### read in data #####
x = read.csv("southerns.csv")
x$row = 1:nrow(x)

##### fix dates #####
datez = x$row[grepl("Nov-", x$session)]
x$date = ifelse(x$row >= datez[1] & x$row < datez[2], x$session[x$row == datez[1]],
                ifelse(x$row >= datez[2] & x$row < datez[3], x$session[x$row == datez[2]],
                       ifelse(x$row >= datez[3], x$session[x$row == datez[3]], NA)))
x = x[x$row %ni% datez,]
x$row = 1:nrow(x)
rm(datez)

##### collapse sessions #####
z = as.data.frame(do.call(rbind, strsplit(x$session, "\\] ")))
z$V1 = gsub("\\[", "", z$V1)
z$row = 1:nrow(z)
y = list()
for(i in (z$row)[z$row %% 2 == 1]){
  z1 = z[z$row == i | z$row == i + 1,]
  y[[length(y)+1]] = data.frame(
    date = x$date[x$row == i],
    time = z1$V1[2],
    session = z1$V1[1],
    title = z1$V2[1]
  )
}
y = as.data.frame(do.call(rbind, y))

##### topics #####
z = openxlsx::read.xlsx("categories.xlsx")
z = z[order(z$topic),]
y$topics = NA
for(i in 1:nrow(z)){
  y$topics = ifelse(grepl(z$title[i], y$title) & is.na(y$topics), z$topic[i],
                    ifelse(grepl(z$title[i], y$title) & !is.na(y$topics) & !grepl(z$topic[i], y$topics), 
                           paste0(y$topics, ", ", z$topic[i]), 
                           y$topics))
}
y$topics[is.na(y$topics)] = "Misc."

##### bar plot #####
x = as.data.frame(table(z$topic))
x = rbind(x, data.frame(Var1 = "Misc.", Freq = 0))
z1 = list()
for(i in 1:nrow(x)){
  z1[[length(z1)+1]] = data.frame(
    topic = x$Var1[i],
    sum = sum(ifelse(grepl(x$Var1[i], y$topics), 1, 0))
  )
}
x = as.data.frame(do.call(rbind, z1))
x = x[order(substring(x$topic, 1, 2)),]
x$nrow = 1:nrow(x)
x = x[order(-x$nrow),]

par(mar=c(4,10,2,2))
bp = barplot(x$sum, xlim = c(0, round(max(x$sum), -1)), horiz = TRUE, 
             names.arg = x$topic, yaxt = "n", xlab = "Number of Sessions",
             cex.lab = 1.5, cex.axis = 1.5)
axis(2, at = bp, labels = x$topic, las = 2)
abline(v = mean(x$sum), lwd = 10000, col = "aliceblue")
abline(v = seq(0, round(max(x$sum), -1), 10), lwd = 2, col = "white")
barplot(x$sum, col = "navyblue", add = TRUE, horiz = TRUE, 
        cex.lab = 1.5, cex.axis = 1.5)
par(mar=c(5,4,4,2)+0.1)

##### csv #####
# write.csv(y, "southerns_schedule.csv", row.names = FALSE)

##### scrape ##### 

chromeCommand <- chrome(retcommand = TRUE, verbose = FALSE, check = FALSE)
chromeCommand

# selenium()
selenium_object <- selenium(retcommand = TRUE, check = FALSE)

# Google chrome
free_ports()
remote_driver <- rsDriver(browser = "chrome",
                          chromever = "119.0.6045.105",
                          verbose = FALSE)

# create a client object
remDr <- remote_driver$client
# remDr$open()
remDr$navigate("https://www.southerneconomic.org/event/7662b305-ad92-474d-8f2c-bce1240b9858/websitePage:efc0c532-2b5f-4374-b1ab-4fae7867ce0b")
for(i in 1:12){
  remDr$executeScript("window.scrollTo(0, document.body.scrollHeight);")
  print(paste("Refresh Scroll", i))
  Sys.sleep(5)
}

# The schedule is constantly changing
y = y[y$time != "Presidential Address and Annual Business Meeting" & 
        y$time != "Featured" & !grepl("Presidential", y$title) & 
        !grepl("Featured", y$title) & y$session != "3.E.18" & 
        y$session != "2.C.26" & y$session != "2.D.17" & y$session != "3.B.29" &
        y$session != "3.C.35",]
y$title[263] = "Water and Natural Disasters"
y$title[300] = "Natural Disasters"
y$title[405] = "Trade, Shock Propagations, and Global Value Chains"

# scrape
z3 = list()
for(k in 1:nrow(y)){
  remDr$findElement(using = 'xpath', 
                    paste0('//*[text()=', '"[', y$session[k], '] ', y$title[k], '"]'))$clickElement()
  
  Sys.sleep(3)
  
  rm = remDr$findElements(using = 'class name', 'carina-rte-public-DraftStyleDefault-block')
  rm = lapply(rm, function (x) x$getElementText())
  
  z1 = list()
  for(i in 1:length(rm)){
    z1[[length(z1)+1]] = data.frame(
      row = i,
      text = as.character(rm[[i]])
    )
  }
  z1 = as.data.frame(do.call(rbind, z1))
  z1 = z1[z1$text != "",]
  z1$row = 1:nrow(z1)
  
  if(TRUE %in% grepl("Papers:", z1$text)){
    
    # main data frame
    z2 = data.frame(
      session = y$session[k],
      paper = matrix(t(as.matrix(z1[min(z1[!grepl("Organizer|Chair|Discussant|Panelist|Moderator", z1$text),1]):max(z1[!grepl("Organizer|Chair|Discussant|Panelist|Moderator", z1$text),1]),2])), 
                     nrow = 1)
    )
    z2[,2] = gsub("Papers:", "", z2[,2])
    
    # organizer(s)
    if(TRUE %in% grepl("Organizer", z1$text)){
      z2$organizer = gsub("Organizer", "", z1[grepl("Organizer", z1$text),2])
    } else{
      z2$organizer = NA
    }
    z2$organizer = trimws(gsub(".*:","",z2$organizer))
    
    # chair(s)
    if(TRUE %in% grepl("Chair:", z1$text)){
      z2$chair = gsub("Chair:", "", z1[grepl("Chair:", z1$text),2])
    } else{
      z2$chair = NA
    }
    z2$chair = trimws(gsub(".*:","",z2$chair))
    if(is.na(z2$chair)){
      if(TRUE %in% grepl("Chairs:", z1$text)){
        z2$chair = gsub("Chairs:", "", z1[grepl("Chairs:", z1$text),2])
      } else{
        z2$chair = NA
      }
      z2$chair = trimws(gsub(".*:","",z2$chair))
    }
    
    # discussant(s)
    if(TRUE %in% grepl("Discussants:", z1$text)){
      z2$discussants = gsub("Discussants:", "", z1[grepl("Discussants:", z1$text),2])
    } else{
      z2$discussants = NA
    }
    z2$discussants = trimws(gsub(".*:","",z2$discussants))
  } 
  if(TRUE %in% grepl("Panelists:", z1$text)){
    
    # main data frame
    z2 = data.frame(
      session = y$session[k],
      panelist = matrix(t(as.matrix(z1[min(z1[grepl("Panelists:", z1$text),1]):max(z1[grepl("Panelists:", z1$text),1]),2])), 
                     nrow = 1)
    )
    z2[,2] = gsub("Panelists:", "", z2[,2])
    
    # organizer(s)
    if(TRUE %in% grepl("Organizer:", z1$text)){
      z2$organizer = gsub("Organizer:", "", z1[grepl("Organizer:", z1$text),2])
    } else{
      z2$organizer = NA
    }
    z2$organizer = trimws(gsub(".*:","",z2$organizer))
    if(is.na(z2$organizer)){
      if(TRUE %in% grepl("Organizers:", z1$text)){
        z2$organizer = gsub("Organizers:", "", z1[grepl("Organizers:", z1$text),2])
      } else{
        z2$organizer = NA
      }
      z2$organizer = trimws(gsub(".*:","",z2$organizer))
    }
    
    # moderator(s)
    if(TRUE %in% grepl("Moderator:", z1$text)){
      z2$moderator = gsub("Moderator:", "", z1[grepl("Moderator:", z1$text),2])
    } else{
      z2$moderator = NA
    }
    z2$moderator = trimws(gsub(".*:","",z2$moderator))
    if(is.na(z2$moderator)){
      if(TRUE %in% grepl("Moderators:", z1$text)){
        z2$moderator = gsub("Moderators:", "", z1[grepl("Moderators:", z1$text),2])
      } else{
        z2$moderator = NA
      }
      z2$moderator = trimws(gsub(".*:","",z2$moderator))
    }
  }
  if(TRUE %ni% grepl("Panelists:|Papers:", z1$text)){
    z2 = data.frame(
      session = y$session[k],
      paper = matrix(t(as.matrix(z1[min(z1[!grepl("Organizer|Chair|Discussant|Panelist|Moderator", z1$text),1]):max(z1[!grepl("Organizer|Chair|Discussant|Panelist|Moderator", z1$text),1]),2])), 
                     nrow = 1)
    )
    # organizer(s)
    if(TRUE %in% grepl("Organizer", z1$text)){
      z2$organizer = gsub("Organizer", "", z1[grepl("Organizer", z1$text),2])
    } else{
      z2$organizer = NA
    }
    z2$organizer = trimws(gsub(".*:","",z2$organizer))
    
    # chair(s)
    if(TRUE %in% grepl("Chair:", z1$text)){
      z2$chair = gsub("Chair:", "", z1[grepl("Chair:", z1$text),2])
    } else{
      z2$chair = NA
    }
    z2$chair = trimws(gsub(".*:","",z2$chair))
    if(is.na(z2$chair)){
      if(TRUE %in% grepl("Chairs:", z1$text)){
        z2$chair = gsub("Chairs:", "", z1[grepl("Chairs:", z1$text),2])
      } else{
        z2$chair = NA
      }
      z2$chair = trimws(gsub(".*:","",z2$chair))
    }
    
    # discussant(s)
    if(TRUE %in% grepl("Discussants:", z1$text)){
      z2$discussants = gsub("Discussants:", "", z1[grepl("Discussants:", z1$text),2])
    } else{
      z2$discussants = NA
    }
    z2$discussants = trimws(gsub(".*:","",z2$discussants))
  } 
  
  z3[[length(z3)+1]] = z2
  
  # close dialog box
  remDr$findElement(using = "class name", "SessionDetailDialog__closeDialog___TdlkW")$clickElement()
}
z4 = as.data.frame(do.call(gtools::smartbind, z3))

# close
remote_driver$server$stop()

##### save work #####

z = as.data.frame(cbind(y, z4[match(y$session, z4$session), 2:ncol(z4)]))

z$date = as.Date(ifelse(substr(z$session, 1, 1) == 1, as.Date("2023-11-18"),
                        ifelse(substr(z$session, 1, 1) == 2, 
                               as.Date("2023-11-19"), as.Date("2023-11-20"))))

# write.csv(z, "southerns 2023 schedule.csv", row.names = FALSE, na = "")
