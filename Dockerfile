FROM rocker/shiny-verse:3.5.0

RUN install2.r shinydashboard DT leaflet

RUN rm -r /srv/shiny-server/*

COPY ./app/ /srv/shiny-server/