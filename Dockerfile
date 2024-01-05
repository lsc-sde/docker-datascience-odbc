# Custom data science notebook for LANDER
ARG OWNER=vvcb
ARG BASE_CONTAINER=jupyter/datascience-notebook
FROM $BASE_CONTAINER

LABEL maintainer="vvcb"

# RUN mkdir /opt/oracle && \
#     cd /opt/oracle && \
#     wget https://download.oracle.com/otn_software/linux/instantclient/216000/instantclient-basic-linux.x64-21.6.0.0.0dbru.zip && \
#     unzip instantclient-basic-linux.x64-21.6.0.0.0dbru.zip

# Install ODBC drivers
# https://github.com/mkleehammer/pyodbc/issues/610
USER root

RUN apt update && \
    apt install -y curl build-essential libssl-dev libffi-dev python3-dev gnupg

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list 
RUN apt update

RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17

RUN ACCEPT_EULA=Y apt-get install -y mssql-tools && \
    echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc && \
    bash -c "source ~/.bashrc"

RUN apt install -y unixodbc-dev libgssapi-krb5-2 && \
    chmod +rwx /etc/ssl/openssl.cnf && \
    sed -i 's/TLSv1.2/TLSv1/g' /etc/ssl/openssl.cnf && \
    sed -i 's/SECLEVEL=2/SECLEVEL=1/g' /etc/ssl/openssl.cnf

COPY jupyter_notebook_config.json /etc/jupyter/jupyter_notebook_config.json

RUN mamba install --quiet --yes \
    'black' \
    'isort' \
    'jupyterlab_code_formatter' \
    'geopandas' \
    'geoviews' \
    'holoviews'  \
    'folium' \
    'datashader' \
    'xeus-sql' \
    'soci-mysql'

RUN mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"



USER ${NB_USER}