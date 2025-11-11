#!/bin/bash
LOG_FILE="/tmp/codedeploy_git_update_process.log"
git --version 2>&1 | tee -a $LOG_FILE
