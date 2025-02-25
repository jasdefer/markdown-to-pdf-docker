# Use an official Python slim image as a base.
FROM python:3.9-slim

# Install OS-level dependencies (excluding Pandoc, which will be installed separately).
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        nodejs \
        npm \
        chromium \
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

# Install the latest Pandoc version from the official releases.
RUN wget -O /tmp/pandoc.deb $(wget -qO- https://api.github.com/repos/jgm/pandoc/releases/latest | \
    grep "browser_download_url.*amd64.deb" | cut -d '"' -f 4) && \
    apt-get update && \
    apt-get install -y --no-install-recommends gdebi-core && \
    gdebi -n /tmp/pandoc.deb && \
    rm -f /tmp/pandoc.deb && \
    pandoc --version

# Install Amiri fonts manually since the fonts-amiri package is not available.
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

# Create a dedicated user for Chromium sandboxing.
# This user is created at build time (with root privileges) so that it’s available in the final image.
RUN groupadd -r chromium && useradd -r -g chromium chromium-sandbox

# Create the regular non-root user (appuser).
RUN useradd --create-home --shell /bin/bash appuser

# Set the working directory and adjust ownership so that appuser can write.
WORKDIR /app
RUN chown -R appuser:appuser /app

# Switch to the non-root user.
USER appuser
