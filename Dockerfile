# Use an official Python slim image as a base.
FROM python:3.9-slim

# Install OS-level dependencies.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        nodejs \
        npm \
        chromium \
        chromium-sandbox \
        texlive-xetex \
        texlive-fonts-recommended \
        texlive-fonts-extra \
        texlive-latex-recommended \
        texlive-lang-arabic \
        lmodern \
        libglib2.0-0 \
        libnss3 \
        libatk1.0-0 \
        libatk-bridge2.0-0 \
        libx11-xcb1 \
        libxcomposite1 \
        libxdamage1 \
        libxrandr2 \
        libgbm1 \
        libxfixes3 \
        libxkbcommon0 \
        libasound2 \
        ca-certificates \
        fonts-liberation \
        fonts-dejavu-core \
        librsvg2-bin \
        wget \
        unzip && \
    rm -rf /var/lib/apt/lists/*

# Install the latest Pandoc version.
RUN wget -O /tmp/pandoc.deb $(wget -qO- https://api.github.com/repos/jgm/pandoc/releases/latest | \
    grep "browser_download_url.*amd64.deb" | cut -d '"' -f 4) && \
    apt-get update && \
    apt-get install -y --no-install-recommends gdebi-core && \
    gdebi -n /tmp/pandoc.deb && \
    rm -f /tmp/pandoc.deb && \
    pandoc --version

# Install Amiri fonts manually.
RUN wget -O /tmp/amiri.zip https://github.com/alif-type/amiri/releases/download/0.115/amiri-0.115.zip && \
    mkdir -p /usr/local/share/fonts/amiri && \
    unzip /tmp/amiri.zip -d /usr/local/share/fonts/amiri && \
    fc-cache -fv && \
    rm -f /tmp/amiri.zip

# Install the Mermaid CLI globally via npm.
RUN npm install -g @mermaid-js/mermaid-cli

# Install Python dependencies.
RUN pip install --no-cache-dir pyyaml

# Tell Puppeteer/Chromium to use the correct executable path.
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# **Fix Chromium sandbox permissions**
RUN chmod 4755 /usr/lib/chromium/chrome-sandbox

# Create a non-root user (vsts) with UID 1001 and set the home directory.
RUN useradd --create-home --uid 1001 --shell /bin/bash vsts

# Set the working directory and change ownership.
WORKDIR /app
RUN chown -R vsts:vsts /app

# Switch to the non-root user.
USER vsts
