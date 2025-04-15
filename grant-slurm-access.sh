#!/bin/bash

# Set MySQL credentials from your Kubernetes secrets
MYSQL_ROOT_PASSWORD=$(kubectl get secret mysql-secret -o jsonpath='{.data.root-password}' | base64 --decode)

# Get the MySQL pod name
MYSQL_POD=$(kubectl get pod -l app=mysql -o jsonpath='{.items[0].metadata.name}')

# SQL command to grant privileges to slurm@%
SQL_CMD="GRANT ALL ON slurm_acct_db.* TO 'slurm'@'%' IDENTIFIED BY 'slurmpass'; FLUSH PRIVILEGES;"

# Execute the command inside the MySQL pod
kubectl exec -i "$MYSQL_POD" -- \
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "$SQL_CMD"
