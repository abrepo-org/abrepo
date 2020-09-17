FROM nginx
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY --from=424385760710.dkr.ecr.us-east-2.amazonaws.com/vergeman/abrepo:latest /app/public/ /app/public/

EXPOSE 80
EXPOSE 443

# Start the main process.
CMD [ "nginx", "-g", "daemon off;" ]
