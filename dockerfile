# Creating multi-stage build for production
FROM node:18-bullseye as build
RUN apt-get update --fix-missing && apt-get install \
  gcc autoconf automake libpng-dev libvips-dev -y && \
  apt-get autoremove && apt-get autoclean
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}
#build-base zlib-dev
WORKDIR /opt/
COPY package.json package-lock.json ./
RUN npm install --only=production
ENV PATH /opt/node_modules/.bin:$PATH
WORKDIR /opt/app
COPY . .
RUN npm run build

# Creating final production image
FROM node:18-bullseye
# RUN apt-get install libvips-dev
# RUN apk add --update --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community --repository http://dl-3.alpinelinux.org/alpine/edge/main vips-dev
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}
WORKDIR /opt/
COPY --from=build /opt/node_modules ./node_modules
WORKDIR /opt/app
COPY --from=build /opt/app ./
ENV PATH /opt/node_modules/.bin:$PATH

RUN chown -R node:node /opt/app
USER node
EXPOSE 1337
CMD ["npm", "run", "start"]
