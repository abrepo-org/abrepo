ARG GIT_COMMIT
FROM 976034468541.dkr.ecr.us-east-2.amazonaws.com/abrepo/abrepo:${GIT_COMMIT} AS abrepo
FROM nginx:stable
RUN apt-get update && apt-get install -y nano
COPY --from=abrepo /app/public/ /app/public/
CMD [ "nginx", "-g", "daemon off;" ]


#
# ARG from docker-compose.build.args:
# https://docs.docker.com/compose/compose-file/build/#args
# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
#
# * COPY --from=<requires image or image alias>
# * ARG is "scoped" to most recent intermediate build: doesn't exist
#   after each FROM and needs to be "redeclared"
#
# GIT_COMMIT arg:
# ./build.sh -> docker-compose.yml -> build arg in this Dockerfile
#
# Toggled via environmental variable (image envstub)
# NB: these are documentation, ports actually published in docker-compose.
# dev, prod, ssl deferred to Cloudflare
# EXPOSE 8080
# EXPOSE 80
# EXPOSE 443
# Start the main process.
