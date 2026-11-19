FROM nginx:stable
RUN apt-get update && apt-get install -y nano
# rails_assets is supplied by Compose from the web service build.
COPY --from=rails_assets /app/public/ /app/public/
CMD [ "nginx", "-g", "daemon off;" ]

# Toggled via environmental variable (image envstub)
# NB: these are documentation, ports actually published in docker-compose.
# dev, prod, ssl deferred to Cloudflare
# EXPOSE 8080
# EXPOSE 80
# EXPOSE 443
# Start the main process.
