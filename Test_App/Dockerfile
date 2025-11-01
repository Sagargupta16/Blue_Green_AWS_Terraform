# Use Node.js image as base
FROM --platform=linux/amd64 public.ecr.aws/docker/library/node:24-alpine AS client-builder

# Set the working directory for the client build
WORKDIR /app/client

# Copy package.json and yarn.lock first for caching dependencies
COPY client/package.json client/yarn.lock ./

# Install client dependencies
RUN yarn install

# Copy the rest of the client-side code
COPY client/ .

# Build the React app for production
RUN yarn build

# Use Node.js image as base for server
FROM --platform=linux/amd64 public.ecr.aws/docker/library/node:24-alpine AS server

# Create and change to the app directory
WORKDIR /app

# Copy package.json and yarn.lock first for caching dependencies
COPY package.json yarn.lock ./

# Install server dependencies
RUN yarn install

# Copy the rest of the server-side code
COPY . .

# Copy the built frontend from the client-builder stage to the server's public directory
COPY --from=client-builder /app/client/build ./client/build

# Expose the port the app runs on
EXPOSE 3000

# Specify the default command to run your app
CMD ["node", "index.js"]
