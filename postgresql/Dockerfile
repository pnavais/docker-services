FROM postgres:10.12
ENV POSTGRES_PASSWORD postgres

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.
COPY conf/custom-init.sh /docker-entrypoint-initdb.d/
