FROM nginx:alpine

# Remove default nginx page
RUN rm -rf /usr/share/nginx/html/*

# Copy only the static site files
COPY index.html error.html styles.css /usr/share/nginx/html/

EXPOSE 80
