# Client build stage
FROM --platform=linux/amd64 public.ecr.aws/docker/library/node:24-alpine AS client-builder

WORKDIR /app/client

COPY client/package.json client/yarn.lock ./
RUN yarn install

COPY client/ .
RUN yarn build

# Server stage
FROM --platform=linux/amd64 public.ecr.aws/docker/library/node:24-alpine AS server

WORKDIR /app

COPY package.json yarn.lock ./
RUN yarn install

COPY . .
COPY --from=client-builder /app/client/build ./client/build

# Drop root and run as the image's built-in node user
RUN chown -R node:node /app
USER node

EXPOSE 3000

CMD ["node", "index.js"]
