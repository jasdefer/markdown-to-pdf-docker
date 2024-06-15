FROM pandoc/latex

# Update TeX Live and install required LaTeX packages
RUN tlmgr update --self && \
    tlmgr install enumitem

# Install Node.js and npm using apk
RUN apk update && \
    apk add --no-cache nodejs npm

# Install Chromium and its dependencies
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont

# Install mermaid-filter globally
RUN npm install --global mermaid-filter

# Set Puppeteer to use installed Chromium and pass --no-sandbox flag
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Create a symlink for Puppeteer to find the Chromium binary
RUN ln -sf /usr/bin/chromium-browser /usr/bin/chromium

# Copy the .puppeteer.json file to the appropriate location
COPY .puppeteer.json /root/.puppeteer.json