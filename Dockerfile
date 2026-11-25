
# Stage 1: Build stage (static website)
FROM nginx:stable-alpine AS base

# Maintainer label
LABEL maintainer="Manasa"
LABEL description="Foodista static website served via Nginx"

# Remove the default Nginx welcome page
RUN rm -rf /usr/share/nginx/html/*

# Copy the entire Foodista project into Nginx web root
COPY . /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
