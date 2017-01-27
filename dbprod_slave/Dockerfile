FROM ubuntu:12.04

# Install dependencies
RUN apt-get update -y

# Install tools
RUN apt-get install -y apt-utils netcat pwgen cron nfs-kernel-server

# Install MySQL
# Configure server for slave status
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --force-yes mysql-server && \
    service mysql stop && \
    sed -e 's/^datadir\t.*$/datadir = \/data/' -i /etc/mysql/my.cnf && \
    sed -e 's/^bind-address\t.*$/bind-address = 0.0.0.0/' -i /etc/mysql/my.cnf && \
    sed -e 's/^\#server-id\t.*$/server-id = 2/' -i /etc/mysql/my.cnf && \
    sed -e 's/^relay_log\t.*$/relay_log = \/var\/log\/mysql\/mysql-relay-bin.log/' -i /etc/mysql/my.cnf && \
    sed -e 's/^\#log_bin\t.*$/log_bin = \/var\/log\/mysql\/mysql-bin.log/' -i /etc/mysql/my.cnf && \
    sed -e 's/^\#binlog_do_db\t.*$/binlog_do_db = users/' -i /etc/mysql/my.cnf && \
    cp /etc/mysql/my.cnf /usr/share/mysql/my-default.cnf && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp*

# Add scripts
ADD scripts /scripts
RUN chmod +x /scripts/*.sh
RUN touch /.firstrun

# Add crontabs
ADD crontab /crontab
RUN crontab /crontab/crontab
RUN touch /var/log/cron.log
#RUN cron && tail -f /var/log/cron.log

# Create location for master backups
RUN mkdir /mysqldumps
RUN chmod 700 /mysqldumps

# Create location for slave backups
RUN mkdir /mysqlbackups
RUN chmod 700 /mysqlbackups
RUN echo '/mysqlbackups/latest 172.17.0.0/24(ro)' >>/etc/exports

# Command to run
ENTRYPOINT ["/scripts/run.sh"]
CMD [""]

# Expose listen port
EXPOSE 3306

# Expose our data directory
VOLUME ["/data", "/var/log/mysql", "/etc/mysql"]
