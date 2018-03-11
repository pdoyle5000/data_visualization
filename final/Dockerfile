FROM r-base:latest

RUN apt-get update && apt-get install -y -t unstable \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev/unstable \
    libxt-dev && \
    wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb && \
    R -e "install.packages(c('shiny', 'rmarkdown', 'openssl', 'httr', 'forcats', 'ggplot2', 'jsonlite', 'anytime', 'plotly', 'shinythemes'), repos='https://cran.rstudio.com/')" && \
    cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/ && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 3838

COPY shiny-server.sh /usr/bin/shiny-server.sh
COPY flat_all2.json /srv/shiny-server/
COPY plugins.json /srv/shiny-server/
COPY ui.R /srv/shiny-server/
COPY global.R /srv/shiny-server/
COPY server.R /srv/shiny-server/
COPY gradleCharts.R /srv/shiny-server/

CMD ["/usr/bin/shiny-server.sh"]