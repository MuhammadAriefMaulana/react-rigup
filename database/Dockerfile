FROM mysql:latest
# AS builder

ENV MYSQL_ROOT_PASSWORD secretadmin

ENV MYSQL_DATABASE=rigdb_rev2
ENV MYSQL_USER=backend
ENV MYSQL_PASSWORD=backend

ADD rigdb_rev2(include-create-schema).sql /docker-entrypoint-initdb.d

# FROM builder
ADD table-view-rev(not-include-create-schema__just-import-to-rigdb_rev2).sql /docker-entrypoint-initdb.d

EXPOSE 3306