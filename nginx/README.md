# NGINX Repo

Nginx serves static files, and load balances on rails puma servers

To serve static files (and pass config) we need to package them into
our own custom nginx container.

This will need to be rebuilt and deployed alongside rails app each
time.

Sprockets keeps 3 versions, so deploy lag should be ok.
