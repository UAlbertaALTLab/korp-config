FROM python:3.10-bookworm
LABEL maintainer="Felipe Bañados Schwerter <banadoss@ualberta.ca>"

ARG KORP_UID_GID=60011

RUN mkdir /app \
&& groupadd --gid ${KORP_UID_GID} korp \
&& useradd --no-log-init --gid korp --create-home --uid ${KORP_UID_GID} korp \
&& chown korp /app 

WORKDIR /app

# Install corpus workbench
RUN set -eux; \
	apt-get update
ADD https://sourceforge.net/projects/cwb/files/cwb/cwb-3.5/source/cwb-3.5.0-src.tar.gz/download cwb_3.5.0-src.tar.gz 
RUN tar -xvzf cwb_3.5.0-src.tar.gz
WORKDIR /app/cwb-3.5.0-src
RUN install-scripts/install-linux

WORKDIR /app
# Download backend version code
ADD https://github.com/spraakbanken/korp-backend/archive/9c6e289c6ba0be38ff1f223cc4711b21e414ff2a.tar.gz korp_backend.tgz
RUN tar -xvzf korp_backend.tgz \
&& mv korp-backend-9c6e289c6ba0be38ff1f223cc4711b21e414ff2a korp-backend

WORKDIR /app/korp-backend
# Install dependencies
RUN pip install -r requirements.txt

# Install gunicorn
RUN pip install gunicorn

COPY config.py instance/config.py

RUN chown -R korp /app \
&& chgrp -R korp /app

USER korp
WORKDIR /app/korp-backend
EXPOSE 1234

# Start server
#CMD ["gunicorn --worker-class gevent --bind 0.0.0.0:1234 --workers 4 --max-requests 250 --limit-request-line 0 'run:create_app()'"]
CMD python3 run.py