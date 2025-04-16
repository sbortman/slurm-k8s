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

# Wait for the munge socket to appear
echo "Waiting for munge socket..."
until [[ -S /var/run/munge/munge.socket.2 ]]; do
  sleep 1
done

# Make sure log and spool dirs exist
mkdir -p /var/log/slurm /var/run/slurm /var/spool/slurm /var/spool/slurmd /var/spool/slurm/state
chown -R slurm:slurm /var/log/slurm /var/run/slurm /var/spool/slurm /var/spool/slurmd

# Start correct slurm daemon as slurm user
case "$ROLE" in
  slurmdbd)
    echo "Starting slurmdbd..."
    exec su -s /bin/bash -c "/usr/sbin/slurmdbd -Dvvv" slurm
    ;;
  slurmctld)
    echo "Starting slurmctld..."
    exec su -s /bin/bash -c "/usr/sbin/slurmctld -Dvvv" slurm
    ;;
  slurmd)
    echo "Starting slurmd..."
    exec su -s /bin/bash -c "/usr/sbin/slurmd -Dvvv" slurm
    ;;
  *)
    echo "Usage: $0 {slurmdbd|slurmctld|slurmd}"
    exit 1
    ;;
esac
