# Stage 1: Build static assets
FROM node:22-alpine AS build
WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# Stage 2: Serve compiled static assets via Nginx
FROM nginx:alpine

# Copies built Vite/React static files to Nginx web root
COPY --from=build /app/dist /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf


# If using Create React App instead of Vite, change /app/dist above to /app/build

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]