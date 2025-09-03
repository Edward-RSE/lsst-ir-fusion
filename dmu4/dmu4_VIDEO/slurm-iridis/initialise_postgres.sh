# Run this script on the host machine for the postgres instance.
# Save the password (to modify the butler_ingest.sh script as
# necessary) and run the following in a screen session from the
# postgres host:

# ssh -R 55432:localhost:5432 [username]@iridis6_b.soton.ac.uk

export POSTGRES_HOME=/srv/docker/postgres

# Name of the database
export POSTGRES_DB=vcrubin-postgresql

# Create the necessary folder structure and generate random password if not already create
d
mkdir -p $POSTGRES_HOME/{config,db/data,run}
export POSTGRES_PASSWORD=$(uuidgen)
echo $POSTGRES_PASSWORD > $POSTGRES_HOME/config/postgres-password
chmod 777 $POSTGRES_HOME/config/postgres-password

# Configure necessary PostgreSQL variables
export POSTGRES_PASSWORD_FILE=$POSTGRES_HOME/config/postgres-password
export POSTGRES_USER=vcrubin
export PGDATA=$POSTGRES_HOME/db/data
export POSTGRES_HOST_AUTH_METHOD=md5
export POSTGRES_INITDB_ARGS="--data-checksums"
export POSTGRES_PORT=5432
export POSTGRES_HOST=localhost

echo ""
echo "------------------------------------------------------------------------------------
----"
echo ""
echo "  PostgreSQL Server Connection Details:"
echo ""
echo "      Server: $POSTGRES_HOST"
echo "        Port: $POSTGRES_PORT"
echo "    Database: $POSTGRES_DB"
echo "    Password: $POSTGRES_PASSWORD"
echo "    Username: $POSTGRES_USER"
echo "    Password: Located in $POSTGRES_HOME/config/postgres-password"
echo ""
echo "------------------------------------------------------------------------------------
---"

docker pull postgres:latest

docker run \
    -p $POSTGRES_PORT:5432 \
    --name vcrubin-postgresql \
    -e PGDATA=$PGDATA \
    -e POSTGRES_INITDB_ARGS=$POSTGRES_INITDB_ARGS \
    -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
    -e POSTGRES_DB=$POSTGRES_DB \
    -e POSTGRES_USER=$POSTGRES_USER \
    -d postgres

sleep 10

# export butler parameters related to db architecture
export SCHEMA_NAMESPACE="vcr_butler_repo"

echo $POSTGRES_PASSWORD

# initialise relevant infrastructure
PGPASSWORD=$POSTGRES_PASSWORD psql --username=$POSTGRES_USER --host=$POSTGRES_HOST --port=
$POSTGRES_PORT -d $POSTGRES_DB -c "CREATE EXTENSION IF NOT EXISTS btree_gist;"
PGPASSWORD=$POSTGRES_PASSWORD psql --username=$POSTGRES_USER --host=$POSTGRES_HOST --port=
$POSTGRES_PORT -d $POSTGRES_DB -c "CREATE SCHEMA $SCHEMA_NAMESPACE;"

