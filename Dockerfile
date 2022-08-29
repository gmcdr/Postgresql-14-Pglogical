FROM ubuntu:22.04

#Postgres 
RUN \
    apt -y update && \
    DEBIAN_FRONTEND="noninteractive" apt install -y postgresql-14  

#Pglogical
RUN apt install postgresql-14-pglogical 

USER postgres

#Create user and restore backup
RUN /etc/init.d/postgresql start &&\
    psql --command "CREATE USER pguser WITH SUPERUSER PASSWORD 'pguser@1';" &&\
    createdb -O pguser pguser 


#Postgres Configuration
RUN \
    echo "local   all             all                                     trust" > /etc/postgresql/14/main/pg_hba.conf && \
    echo "host    all             all             0.0.0.0/0               trust" >> /etc/postgresql/14/main/pg_hba.conf && \
    echo "host    all             all             ::1/128                 trust" >> /etc/postgresql/14/main/pg_hba.conf && \
    echo "local   replication     all                                     trust" >> /etc/postgresql/14/main/pg_hba.conf && \
    echo "host    replication     all             127.0.0.1/32            trust" >> /etc/postgresql/14/main/pg_hba.conf && \
    echo "host    replication     all             ::1/128                 trust" >> /etc/postgresql/14/main/pg_hba.conf && \
    echo "host all all all scram-sha-256" >> /etc/postgresql/14/main/pg_hba.conf && \
    echo "wal_level = 'logical'" >> /etc/postgresql/14/main/postgresql.conf && \
    echo "listen_addresses='*'" >> /etc/postgresql/14/main/postgresql.conf && \
    echo "max_replication_slots = 10" >> /etc/postgresql/14/main/postgresql.conf && \
    echo "max_worker_processes = 8" >> /etc/postgresql/14/main/postgresql.conf && \
    echo "max_wal_senders = 10" >> /etc/postgresql/14/main/postgresql.conf && \
    echo "shared_preload_libraries = 'pglogical'" >> /etc/postgresql/14/main/postgresql.conf && \
    echo "pglogical.conflict_resolution = 'last_update_wins'" >> /etc/postgresql/14/main/postgresql.conf 


VOLUME /etc/postgresql/14/main

EXPOSE 5432

CMD ["/usr/lib/postgresql/14/bin/postgres", "-D", "/var/lib/postgresql/14/main", "-c", "config_file=/etc/postgresql/14/main/postgresql.conf"]

#ByGabrielReis