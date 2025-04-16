FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y slurm-wlm slurmdbd mysql-client munge && \
    id slurm || useradd -m slurm && \
    usermod -d /home/slurm -s /bin/bash slurm && \
    mkdir -p /home/slurm && chown slurm /home/slurm    

COPY entrypoint.sh /entrypoint.sh

COPY ./conf/slurmdbd.conf /etc/slurm/slurmdbd.conf
RUN chmod 600 /etc/slurm/slurmdbd.conf && \
    chown slurm:slurm /etc/slurm/slurmdbd.conf && \
    chmod +x /entrypoint.sh && \
    mkdir -p /etc/munge && \
    dd if=/dev/urandom bs=1 count=1024 2>/dev/null | base64 > /etc/munge/munge.key && \
    chmod 400 /etc/munge/munge.key && \
    chown -R munge:munge /etc/munge && \
    mkdir -p /var/log/munge && chown munge:munge /var/log/munge

ENTRYPOINT ["/entrypoint.sh"]
