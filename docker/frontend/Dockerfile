FROM node:22-bookworm AS builder
LABEL maintainer="Felipe Bañados Schwerter <banadoss@ualberta.ca>"

ARG KORP_UID_GID=60005

RUN mkdir /app \
&& groupadd --gid ${KORP_UID_GID} korp \
&& useradd --no-log-init --gid korp --create-home --uid ${KORP_UID_GID} korp \
&& chown korp /app 

WORKDIR /app

# Install corpus workbench
RUN set -eux; \
	apt-get update

# Download frontend code
ADD https://github.com/spraakbanken/korp-frontend/archive/684b485f5168cabb7ed03f8ae73b2e6b71f814f9.tar.gz korp_frontend.tgz
RUN tar -xvzf korp_frontend.tgz \
&& mv korp-frontend-684b485f5168cabb7ed03f8ae73b2e6b71f814f9 korp-frontend

WORKDIR /app
ADD https://api.github.com/repos/UAlbertaALTLab/korp-config/git/refs/heads/main version.json
RUN git clone -b main https://github.com/UAlbertaALTLab/korp-config.git

WORKDIR /app/korp-frontend
# Tell the frontend about the config folder
COPY run_config.json run_config.json
# Add our local variations.  If more changes are added, we should just fork the frontend as well, but for now this works.
COPY locale-eng.json app/translations/locale-eng.json
COPY header.js app/scripts/components/header.js
COPY simple-search.js app/scripts/components/simple-search.js
COPY util.ts app/scripts/util.ts
COPY altlab-export.svg app/img/altlab.svg
RUN yarn install
RUN yarn build

###### Application image ######

FROM nginx
LABEL maintainer="Felipe Bañados Schwerter <banadoss@ualberta.ca>"
COPY --from=builder /app/korp-frontend/dist /usr/share/nginx/html