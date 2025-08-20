# export POSTGRES_HOME=/iridisfs/scratch/$(whoami)
export POSTGRES_HOME=/home/jamie/Experimentation/vcrpostgres

# Name of the database
export POSTGRES_DB=vcrubin-postgresql

# Create the necessary folder structure and generate random password if not already created
mkdir -p $POSTGRES_HOME/{config,db/data,run}
export POSTGRES_PASSWORD=$(uuidgen)
echo $POSTGRES_PASSWORD > $POSTGRES_HOME/config/postgres-password
chmod 777 $POSTGRES_HOME/config/postgres-password

# Configure necessary PostgreSQL variables
export POSTGRES_PASSWORD_FILE=$POSTGRES_HOME/config/postgres-password
export POSTGRES_USER=$USER
export PGDATA=$POSTGRES_HOME/db/data
export POSTGRES_HOST_AUTH_METHOD=md5
export POSTGRES_INITDB_ARGS="--data-checksums"
export POSTGRES_PORT=$(shuf -i 10000-30000 -n 1) # select a random port to run on
export POSTGRES_HOST=$(hostname)

echo ""
echo "----------------------------------------------------------------------------------------"
echo ""
echo "  PostgreSQL Server Connection Details:"
echo ""
echo "      Server: $POSTGRES_HOST"
echo "        Port: $POSTGRES_PORT"
echo "    Database: $POSTGRES_DB"
echo "    Username: $USER"
echo "    Password: Located in $POSTGRES_HOME/config/postgres-password"
echo ""
echo "---------------------------------------------------------------------------------------"

# load apptainer
# module load apptainer

# pull then run postgresql via apptainer

apptainer pull postgres.sif docker://postgres:latest
# docker pull postgres:latest

apptainer run --unsquash postgres.sif -c
# docker run \
#    -p $POSTGRES_PORT:5432 \
#    --name vcrubin-postgresql \
#    -e PGDATA=$PGDATA \
#    -e POSTGRES_INITDB_ARGS=$POSTGRES_INITDB_ARGS \
#    -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
#    -e POSTGRES_DB=$POSTGRES_DB \
#    -e POSTGRES_USER=$POSTGRES_USER \
#    -d postgres

# make sure pgres is up and healthy before performing queries
sleep 2

# export butler parameters related to db architecture
export SCHEMA_NAMESPACE="vcr_butler_repo"

# initialise relevant infrastructure
PGPASSWORD=$POSTGRES_PASSWORD psql --host=$POSTGRES_HOST --port=$POSTGRES_PORT -d $POSTGRES_DB -c "CREATE EXTENSION IF NOT EXISTS btree_gist;"
PGPASSWORD=$POSTGRES_PASSWORD psql --host=$POSTGRES_HOST --port=$POSTGRES_PORT -d $POSTGRES_DB -c "CREATE SCHEMA $SCHEMA_NAMESPACE;"

