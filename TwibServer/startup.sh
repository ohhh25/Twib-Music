#!/bin/bash

# Define the warning message
WARN_MSG="WARNING: ONLY USE THIS SCRIPT IF YOU ARE RUNNING THE SERVER ON A
 LINUX MACHINE AND ARE DEPLOYING THE SERVER PUBLICLY ON THE INTERNET"

SUCCESS_MSG="Server started successfully. Logs are being displayed and saved
 to twib_logs.txt. Press Ctrl+C to stop displaying logs and stop the server."

# Function to handle script interruption
# This function will be called when the user presses Ctrl+C
cleanup() {
    # Documentation below generated from GitHub Copilot
    # This script logs the interruption of the script by the user, notifies the user of the cancellation,
    # stops all PM2 processes, and exits with a status code of 1.
    # 
    # - Logs the current date and a message indicating the script was interrupted by the user to 'twib_logs.txt'.
    # - Prints a message to the console indicating the operation was canceled by the user.
    # - Stops all running PM2 processes.
    # - Exits the script with a status code of 1.
    echo "$(date) - Script interrupted by user." >> twib_logs.txt
    echo -e "\nOperation canceled by user."
    pm2 stop all
    exit 1
}

# Set up the trap to catch SIGINT (Ctrl+C)
trap cleanup SIGINT

# Print the warning message
echo "$WARN_MSG"
echo "Press any key to continue...Press Ctrl+C to cancel."
read -n 1 -s

# Install the required dependencies
npm install || { echo "npm install failed"; exit 1; }

# Set the environment variables
export SCOPE="public"
export PORT="80"

# Stop the server if it is already running
pm2 stop all

# Start the server with name "Twib-Server"
pm2 start server.mjs --name Twib-Server || { echo "Failed to start the server"; exit 1; }
pm2 save
echo -e "\n$SUCCESS_MSG"

# Display the logs from process "Twib-Server" and save them to twib_logs.txt
{
    pm2 logs Twib-Server | tee twib_logs.txt
} &

# Capture the background process ID
PM2_LOG_PID=$!

# Wait for the logging process to finish
wait $PM2_LOG_PID

# After the wait, perform cleanup or additional tasks
echo "Log monitoring finished."
