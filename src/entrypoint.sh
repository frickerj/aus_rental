#!/bin/bash

PROJECT_ID="ausrental"

gcloud config set project $PROJECT_ID

python3 src/flatmates_scraper.py
