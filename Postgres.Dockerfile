FROM postgres:9-alpine
RUN mkdir -p /docker-entrypoint-initdb.d
COPY heliossql.init /docker-entrypoint-initdb.d/heliossql.sql
