#!/bin/bash

# by default nginx is dormant so we need to start it on each run
service nginx start

# get into the proper directory
cd /app

# run the app
exec gunicorn --config /app/config.py main:app
# exec gunicorn --bind unix:/app/gunicorn.sock --worker-class gthread --workers 2 --timeout 120 main:app
