distancr
=============

Motivation
----------
Amidst the confusion and danger surrounding SARS-CoV-2 and COVID-19, it is crucial to take precautions against accidental exposure to the virus and disease. While social distancing regulations have been relaxed in the state of Georgia, we urge everyone to remain careful about the potential for transmission. For most people, grocery shopping is one of the only tasks urgent enough to leave home for; hence, we propose an application to limit or otherwise reduce exposure to the Coronavirus during these grocery trips.

How it Works
------------
To use the app, select which grocery store you want to go to (e.g., Kroger or Walmart) and enter your zip code and how far you are willing to travel in miles. The relevant results will be returned on the map and in the table. The COVID score indicates the level of risk associated with a specific location, or specifically, the number of cases of COVID-19 that are likely to be at the store. Red values indicate above-average risk while green values indicate below-average risk. The table can be sorted by any of the attributes, and specific rows may be expanded to determine the expected number of shoppers per day (so, a lower number is a less risky day to shop).

Risk Calculation
------------
Using a mix of proprietary and publicly available datasests, we calculated the expected number of people infected with COVID per census block group. While symptomatic people likely take efforts not to shop at grocery stores themselves, we use the number reported (mostly symptomatic) cases as a proxy for asymptomatic people who exhibit the same shopping behavior as healthy people. This assumption is based on multiple testing studies that suggest 50% of COVID cases are asymptomatic. Then for each point of interest in our dataset, we used the  distribution of visitor home county and Census Block Group (CBG) to calculate the store's expected number of COVID visitors per day. This method also assumes that foot-traffic to a particular store is static for a given month, but does account for daily changes in reported COVID cases.

Future Work
------------
We plan on sorting the relevant stores by risk as the default option as the primary purpose of our application is to reduce the risk of shoppers in Atlanta. We may also improve our risk calculation method and UI interface.

Technical Requirements
----------------------

**Instructions and platform specifications**

>**Languages and tools used:**
>
>- R Studio
>- Reactable
>- Shiny 
>- Shinydashboard
>- Sp
>- Tidyverse
>- Geosphere
>- Leaflet
>
>**Instructions**
>
>1. Project is listed at https://sharvil09.shinyapps.io/test/.

