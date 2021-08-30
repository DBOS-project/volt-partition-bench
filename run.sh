#!/usr/bin/env bash

# find voltdb binaries
if [ -e ../../bin/voltdb ]; then
    # assume this is the examples folder for a kit
    VOLTDB_BIN="$(dirname $(dirname $(pwd)))/bin"
elif [ -n "$(which voltdb 2> /dev/null)" ]; then
    # assume we're using voltdb from the path
    VOLTDB_BIN=$(dirname "$(which voltdb)")
else
    echo "Unable to find VoltDB installation."
    echo "Please add VoltDB's bin directory to your path."
    exit -1
fi

# call script to set up paths, including
# java classpaths and binary paths
source $VOLTDB_BIN/voltenv

# leader host for startup purposes only
# (once running, all nodes are the same -- no leaders)
STARTUPLEADERHOST="localhost"
# list of cluster nodes separated by commas in host[:port] format
SERVERS="localhost"

# remove binaries, logs, runtime artifacts, etc... but keep the jars
function clean() {
    rm -rf voltdbroot log *.class
}

# remove everything from "clean" as well as the jarfiles
function cleanall() {
    clean
    rm -rf account-transfer-client.jar account-transfer-proc.jar 
}

# compile the source code for procedures and the client into jarfiles
function jars() {
    # compile java source
    javac -classpath $CLIENTCLASSPATH AccountTransfer.java
    javac -classpath $APPCLASSPATH Transfer1.java Transfer2.java 
    
    # build procedure and client jars
    jar cf account-transfer-client.jar *.class
    jar cf account-transfer-proc.jar *.class

    # remove compiled .class files
    rm -rf *.class
}

# compile the procedure and client jarfiles if they don't exist
function jars-ifneeded() {
    if [ ! -e account-transfer-client.jar ]; then
        jars;
    fi
    if [ ! -e account-transfer-proc.jar ]; then
        jars;
    fi
}

# Init to directory voltdbroot
function voltinit-ifneeded() {
    voltdb init --force --config=deployment.xml
}

# run the voltdb server locally
function server() {
    voltinit-ifneeded
    voltdb start -H $STARTUPLEADERHOST
}

# load schema and procedures
function init() {
    jars-ifneeded
    sqlcmd < ddl.sql
}

# Use this target for argument help
function client-help() {
    jars-ifneeded
    java -classpath account-transfer-client.jar:$CLIENTCLASSPATH AccountTransfer --help
}

# run the client that drives the example with some editable options
function client() {
    jars-ifneeded
    java -classpath account-transfer-client.jar:$CLIENTCLASSPATH AccountTransfer \
        --duration=60 \
        --accounts=1000 \
        --spratio=1 \
        --servers=$SERVERS
}

function help() {
    echo "Usage: ./run.sh {clean|cleanall|jars|server|init|client|client-help}"
}

# Run the targets pass on the command line
# If no first arg, run server
if [ $# -eq 0 ]; then server; exit; fi
for arg in "$@"
do
    echo "${0}: Performing $arg..."
    $arg
done
