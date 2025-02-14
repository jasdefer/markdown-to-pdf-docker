FROM pandoc/latex

# Update TeX Live and install required LaTeX packages
RUN tlmgr update --self && \
    tlmgr install enumitem 

# Install Node.js and npm using apk
RUN apk update && \
    apk add --no-cache nodejs npm

# Install Chromium and its dependencies (without ttf-amiri)
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont

# Manually install Amiri font
RUN mkdir -p /usr/share/fonts/truetype/amiri && \
    wget -O /tmp/amiri.zip https://github.com/alif-type/amiri/releases/download/0.117/amiri-0.117.zip && \
    unzip /tmp/amiri.zip -d /tmp/amiri && \
    cp /tmp/amiri/Amiri-0.117/Amiri-Regular.ttf /usr/share/fonts/truetype/amiri/ && \
    cp /tmp/amiri/Amiri-0.117/Amiri-Bold.ttf /usr/share/fonts/truetype/amiri/ && \
    cp /tmp/amiri/Amiri-0.117/Amiri-Slanted.ttf /usr/share/fonts/truetype/amiri/ && \
    cp /tmp/amiri/Amiri-0.117/Amiri-BoldSlanted.ttf /usr/share/fonts/truetype/amiri/ && \
    fc-cache -fv && \
    rm -rf /tmp/amiri /tmp/amiri.zip

# Install mermaid-filter globally
RUN npm install --global mermaid-filter

# Set Puppeteer to use installed Chromium and pass --no-sandbox flag
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Create a symlink for Puppeteer to find the Chromium binary
RUN ln -sf /usr/bin/chromium-browser /usr/bin/chromium

# Copy the .puppeteer.json file to the appropriate location
COPY .puppeteer.json /root/.puppeteer.json

# Copy the entrypoint script and set the appropriate permissions
COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

# Set the entrypoint to the entrypoint script
ENTRYPOINT ["/root/entrypoint.sh"]
