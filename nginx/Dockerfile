FROM nginx
COPY --from=424385760710.dkr.ecr.us-east-2.amazonaws.com/vergeman/abrepo:latest /app/public/ /app/public/

# Toggled via environmental variable (image envstub)
# NB: these are documentation, ports actually published in docker-compose.
# dev, prod, ssl deferred to Cloudflare
# EXPOSE 8080
# EXPOSE 80
# EXPOSE 443

# Start the main process.
CMD [ "nginx", "-g", "daemon off;" ]
