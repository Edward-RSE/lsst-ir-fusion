!/bin/bash

export POSTGRES_HOME=/iridisfs/scratch/$(whoami)

# Name of the database
export POSTGRES_DB=vcrubin-postgresql

# Create the necessary folder structure and generate random password if not already created
mkdir -p $POSTGRES_HOME/{config,db/data,run}
[ ! -f "$POSTGRES_HOME/config/postgres-password" ] && uuidgen > $POSTGRES_HOME/config/postgres-password
chmod 777 $POSTGRES_HOME/config/postgres-password

# Configure necessary PostgreSQL variables
export POSTGRES_PASSWORD_FILE=$POSTGRES_HOME/config/postgres-password
export POSTGRES_USER=$USER
export PGDATA=$POSTGRES_HOME/db/data
export POSTGRES_HOST_AUTH_METHOD=md5
export POSTGRES_INITDB_ARGS="--data-checksums"
export POSTGRES_PORT=$(shuf -i 10000-30000 -n 1) # select a random port to run on

echo ""
echo "----------------------------------------------------------------------------------------"
echo ""
echo "  PostgreSQL Server Connection Details:"
echo ""
echo "      Server: $(hostname)"
echo "        Port: $POSTGRES_PORT"
echo "    Database: $POSTGRES_DB"
echo "    Username: $USER"
echo "    Password: Located in $POSTGRES_HOME/config/postgres-password"
echo ""
echo "---------------------------------------------------------------------------------------"

# load apptainer
module load apptainer

# pull then run postgresql via apptainer

apptainer pull postgres.sif docker://postgres:latest
apptainer run --unsquash -B $POSTGRES_HOME/db:/var/lib/postgresql -B $POSTGRES_HOME/run:/var/run/postgresql postgres.sif -c "port=$POSTGRES_PORT"
apptainer instance list

