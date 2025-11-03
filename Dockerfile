# Production stage
FROM nginx:alpine

# Copy custom nginx config if needed
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy build files to NGINX html folder
COPY dist /usr/share/nginx/html

# Expose port 3000
EXPOSE 3000

# Update nginx to listen on port 3000
RUN sed -i 's/listen       80;/listen       3000;/g' /etc/nginx/conf.d/default.conf

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

