#!/bin/sh

# Copy the .puppeteer.json file to the current working directory
cp /root/.puppeteer.json .

# Execute the given command
exec pandoc "$@"