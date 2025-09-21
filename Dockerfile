FROM python:3.9-slim
USER root

# RUN apt-get update && apt-get install -y prelink
# RUN execstack -c /usr/local/lib/python3.9/site-packages/torch/lib/libtorch_cpu.so

# RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list \
#     && echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

COPY requirements.txt /app/
RUN pip install --upgrade pip setuptools wheel
RUN pip install -r /app/requirements.txt




# Install system level dependencies
RUN apt-get update &&\
    apt-get install -y \
    gcc\
    git-all\
    libsm6\
    libxext6\
    musl-dev\
    nano\
    nginx\
    python3-dev\
    python3-pip\
    systemd\
    unzip\
    wget\
    zip\
    libgl1 \
    libglib2.0-0 \
    -y\
    && apt-get autoremove -y\
    && apt-get clean -y\
    && rm -rf /var/lib/apt/lists/*

# Copy nginx configuration file, pip requirements, entrypoint script, and get-pip.py script
ADD nginx_host /etc/nginx/sites-enabled/default
ADD entrypoint.sh /entrypoint.sh
ADD config.py /app/config.py
ADD app/requirements.txt /app/requirements.txt
ADD get-pip.py /app/get-pip.py
ADD yolov5 /app/yolov5
ADD /app/best.pt /app/best.pt


# Install pip and dependencies using the locally copied get-pip.py
RUN python3 /app/get-pip.py \
    && python3 -m pip install -U pip \
    && python3 -m pip install -r /app/requirements.txt \
    && python3 -m pip install gunicorn

# Copy the app to be used when starting the Docker container and set permissions
COPY ./app /app
RUN chmod +x /entrypoint.sh && chmod -R 755 /app

EXPOSE 80

CMD  ["/entrypoint.sh"]
