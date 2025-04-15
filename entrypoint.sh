#!/bin/bash
set -euo pipefail

ROLE="${1:-}"

# Ensure /run/munge exists and has correct permissions
mkdir -p /run/munge
chown munge:munge /run/munge
chmod 755 /run/munge

# Create munge key if it doesn't exist
if [ ! -f /etc/munge/munge.key ]; then
    echo "Creating munge key..."
    /usr/sbin/create-munge-key
    chown munge:munge /etc/munge/munge.key
    chmod 400 /etc/munge/munge.key
fi

# Start munged
echo "Starting munged..."
/usr/sbin/munged --force --verbose

# Make sure log and spool dirs exist
mkdir -p /var/log/slurm /var/run/slurm /var/spool/slurm /var/spool/slurmd /var/spool/slurm/state
chown -R slurm:slurm /var/log/slurm /var/run/slurm /var/spool/slurm /var/spool/slurmd

# Start correct slurm daemon
case "$ROLE" in
  slurmdbd)
    echo "Starting slurmdbd..."
    exec /usr/sbin/slurmdbd -Dvvv
    ;;
  slurmctld)
    echo "Starting slurmctld..."
    exec /usr/sbin/slurmctld -Dvvv
    ;;
  slurmd)
    echo "Starting slurmd..."
    exec /usr/sbin/slurmd -Dvvv
    ;;
  *)
    echo "Usage: $0 {slurmdbd|slurmctld|slurmd}"
    exit 1
    ;;
esac
