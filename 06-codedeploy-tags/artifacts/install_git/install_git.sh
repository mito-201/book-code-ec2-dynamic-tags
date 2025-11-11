#!/bin/bash
LOG_FILE="/tmp/codedeploy_git_update_process.log"
dnf install -y git-2.47.1-1.amzn2023.0.2 2>&1 | tee -a $LOG_FILE
