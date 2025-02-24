FROM pandoc/latex

# Update TeX Live and install required LaTeX packages
RUN tlmgr update --self && \
    tlmgr install enumitem

# Install all necessary packages in one layer:
# - Node.js and npm (with required SQLite libraries)
# - Utilities: wget, unzip, fontconfig
# - SQLite development files (to resolve Node relocation issues)
# - Chromium and its dependencies
RUN apk update && apk add --no-cache \
    nodejs \
    npm \
    wget \
    unzip \
    fontconfig \
    sqlite \
    sqlite-libs \
    sqlite-dev \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont

# Manually install Amiri font and update font cache
RUN mkdir -p /usr/share/fonts/truetype/amiri && \
    wget -O /tmp/amiri.zip https://github.com/alif-type/amiri/releases/download/0.117/amiri-0.117.zip && \
    unzip /tmp/amiri.zip -d /tmp/amiri && \
    cp /tmp/amiri/Amiri-0.117/Amiri-Regular.ttf /usr/share/fonts/truetype/amiri/ && \
    cp /tmp/amiri/Amiri-0.117/Amiri-Bold.ttf /usr/share/fonts/truetype/amiri/ && \
    cp /tmp/amiri/Amiri-0.117/Amiri-Slanted.ttf /usr/share/fonts/truetype/amiri/ && \
    cp /tmp/amiri/Amiri-0.117/Amiri-BoldSlanted.ttf /usr/share/fonts/truetype/amiri/ && \
    fc-cache -fv && \
    rm -rf /tmp/amiri /tmp/amiri.zip

# Install mermaid-filter globally via npm
RUN npm install --global mermaid-filter

# Configure Puppeteer to use the installed Chromium binary.
# Chromium on Alpine is at /usr/bin/chromium so we create a symlink for Puppeteer
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

RUN ln -sf /usr/bin/chromium /usr/bin/chromium-browser

# Copy configuration and entrypoint script
COPY .puppeteer.json /root/.puppeteer.json
COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

# Set the entrypoint to the script
ENTRYPOINT ["/root/entrypoint.sh"]
