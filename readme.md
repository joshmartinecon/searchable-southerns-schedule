# Searchable SEA Schedule

Overwhelmed by the number of sessions at the Southern Economic Association meeting? Me too.

## The Problem

The [program schedule](https://www.southerneconomic.org/event/7662b305-ad92-474d-8f2c-bce1240b9858/websitePage:efc0c532-2b5f-4374-b1ab-4fae7867ce0b) is not good. The primary issues are:

1. The information in the website it not easily accessible.
    a. Each session must be **manually** clicked to access any information.
2. There is no way to search for authors by name or affiliation.
3. The filter function only identifies sub-group affiliated sessions.

These become a larger problem when there are 489 sessions in three days.

## An Attempted Solution

I created an searchable app for interacting with the Southerns schedule. If apps aren't your thing, you can directly download the data here.

## Topics

I very crudely attempt to identify the main topic of the session based on the phrases used in the session title. You can find my phrase-to-topic crosswalk here. Very open to suggestions.

<a><img src="barplot.png"></a>

[Source Code](https://github.com/joshmartinecon/sports-on-tv/blob/main/nba.R)

## Web Crawler Code

My code is a mess. Sorry. Reach out if you have questions.

<a><img src="my coding.jpg" width="400"></a>

[Source Code](https://github.com/joshmartinecon/sports-on-tv/blob/main/nba.R)

## Shout Out

Special thank you to [Samer Hijjazi](https://www.youtube.com/@SamerHijjazi) for his incredible content on scraping difficult-to-webcrawl websites. If you wish to use my code and are unfamiliar with RSelenium, I highly recommend viewing his content on YouTube first.
