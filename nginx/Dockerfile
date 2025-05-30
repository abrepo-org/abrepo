ARG GIT_COMMIT=ce66db9
FROM 976034468541.dkr.ecr.us-east-2.amazonaws.com/abrepo/abrepo:${GIT_COMMIT} AS abrepo
FROM nginx:stable
RUN apt-get update && apt-get install -y nano
COPY --from=abrepo /app/public/ /app/public/
CMD [ "nginx", "-g", "daemon off;" ]

#
# * COPY --from=<requires image or image alias>
# * ARG is "scoped" to most recent intermediate build: doesn't exist
#   after each FROM and needs to be "redeclared"
#

# Toggled via environmental variable (image envstub)
# NB: these are documentation, ports actually published in docker-compose.
# dev, prod, ssl deferred to Cloudflare
# EXPOSE 8080
# EXPOSE 80
# EXPOSE 443
# Start the main process.
