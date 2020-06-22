# Ubuntu 18.04 base with Python runtime and pyodbc to connect to SQL Server
FROM ubuntu:18.04

WORKDIR /app

# apt-get and system utilities
RUN apt-get update && apt-get install -y \
    curl apt-utils apt-transport-https debconf-utils gcc build-essential g++-5\
    && rm -rf /var/lib/apt/lists/*

# adding custom Microsoft repository
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

# install SQL Server drivers
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql17 unixodbc-dev

# install SQL Server tools
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y mssql-tools
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"

# python libraries
RUN apt-get update -y && \
    apt-get install -y python3-pip python3-dev

# install necessary locales, this prevents any locale errors related to Microsoft packages
RUN apt-get update && apt-get install -y locales \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen

#Copy local code to the container image.
ENV APP_HOME /app
WORKDIR $APP_HOME
COPY . ./

#Install gunicorn to run it with exec
RUN pip3 install Flask gunicorn

#Install pyodbc (and, optionally, sqlalchemy)
RUN pip3 install -r requirements.txt

#Run app.py upon container launch
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 app:app
