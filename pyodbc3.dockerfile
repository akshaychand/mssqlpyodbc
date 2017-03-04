# To build:
# docker build -f pyodbc3.dockerfile -t akshaychand/pyodbc3mssql .
# Python runtime with pyodbc to connect to SQL Server

FROM ubuntu:16.04

# apt-get and system utilities
RUN apt-get update && apt-get install -y \
    curl apt-utils apt-transport-https debconf-utils gcc build-essential g++-5\
    && rm -rf /var/lib/apt/lists/*

# adding custom MS repository
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

# install SQL Server drivers
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql unixodbc-dev

# install SQL Server tools
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y mssql-tools
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"

# python libraries
RUN curl -LO https://repo.continuum.io/archive/Anaconda3-4.2.0-Linux-x86_64.sh && \
    bash Anaconda3-4.2.0-Linux-x86_64.sh -p /Anaconda3 -b && \
    rm Anaconda3-4.2.0-Linux-x86_64.sh && \
    rm -rf /var/lib/apt/lists/*

ENV PATH /Anaconda/bin:$PATH

# Update conda packages
RUN conda update -y conda && \
    pip install --upgrade pip && \
    pip install pyodbc

# install necessary locales
RUN apt-get install -y locales \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen

# install additional utilities
RUN apt-get update && apt-get install gettext nano vim -y

# add sample code
RUN mkdir /sample
ADD . /sample
WORKDIR /sample

CMD /bin/bash ./entrypoint.sh
