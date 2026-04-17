# 1) choose base container
# generally use the most recent tag
# base notebook, contains Jupyter and relevant tools
# See https://github.com/ucsd-ets/datahub-docker-stack/wiki/Stable-Tag 
# for a list of the most current containers we maintain
ARG BASE_CONTAINER=ghcr.io/ucsd-ets/rstudio-notebook:2025.2-stable
FROM $BASE_CONTAINER
LABEL maintainer="UC San Diego ITS/ETS <ets-consult@ucsd.edu>"

# 2) change to root to install packages
USER root
RUN apt-get update && apt-get -y install htop

# Install playwright system dependencies
RUN apt-get install -y \
    libnss3 \
    libatk-bridge2.0-0 \
    libdrm2 \
    libxkbcommon0 \
    libgbm1 \
    libasound2 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libpango-1.0-0 \
    libcairo2 \
    && apt-get clean

# 3) install packages using notebook user
USER jovyan

# Original packages
RUN pip install --no-cache-dir networkx scipy

# Web scraping & parsing
RUN pip install --no-cache-dir \
    requests \
    beautifulsoup4 \
    lxml \
    playwright \
    httpx

# PDF handling
RUN pip install --no-cache-dir \
    pymupdf \
    pdfplumber \
    pypdf2

# Data output & spreadsheet
RUN pip install --no-cache-dir \
    pandas \
    openpyxl

# CLI tool packaging
RUN pip install --no-cache-dir \
    click \
    typer \
    rich \
    tqdm \
    pydantic \
    python-dotenv

# NLP & stretch goal packages
RUN pip install --no-cache-dir \
    spacy \
    scispacy \
    transformers \
    sentence-transformers \
    torch --index-url https://download.pytorch.org/whl/cpu

# Download spaCy English model
RUN python -m spacy download en_core_web_sm

# Install playwright browsers
RUN playwright install chromium

# Testing
RUN pip install --no-cache-dir pytest

USER root
RUN mamba install -c conda-forge r-survey -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER && \
    mamba clean -a -y

USER jovyan

# Override command to disable running jupyter notebook at launch
# CMD ["/bin/bash"]
