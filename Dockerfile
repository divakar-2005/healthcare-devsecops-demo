FROM nginx:alpine

# Run Nginx on non-privileged port 8080 so root is not required
RUN sed -i 's/listen  *80;/listen 8080;/g' /etc/nginx/conf.d/default.conf && \
    chown -R nginx:nginx /var/cache/nginx /var/run /var/log/nginx /etc/nginx/conf.d

COPY index.html /usr/share/nginx/html/index.html

# Drop root privileges
USER nginx
EXPOSE 8080
