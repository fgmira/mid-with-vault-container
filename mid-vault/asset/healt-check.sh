#!/bin/bash
#

# Print log message with timestamp
logInfo () {
  msg="$(date '+%Y-%m-%dT%T.%3N') ${1}"
  echo "$msg" | tee -a ${LOG_FILE}
}

# Check if mid server is healthy
# Return 0 if healthy, 1 if unhealthy
checkMidServer(){
    if [ ! -f agent/work/mid.pid ]
    then
        logInfo "agent/work/mid.pid doesn't exist"
        return 1
    fi

    if [ ! -f agent/.healthcheck ]
    then
        logInfo "agent/.healthcheck doesn't exist"
        return 1
    fi

    # check if currentTime - lastModifiedTime of .healthcheck is >= 30 min (1800 sec) \
    currentTime=`date '+%s'`
    lastModifiedTime=`date -r agent/.healthcheck '+%s'`

    if [ $(($currentTime-$lastModifiedTime)) -gt 1800 ]
    then
        logInfo "agent/.healthcheck is older than 30 minutes"
        return 1
    fi

    return 0
}

# Check if vault agent is healthy
# Return 0 if healthy, 1 if unhealthy
checkVaultAgent(){
    # check if vault-agent.pid exists
    if [ ! -f ./vault-agent.pid ]
    then
        logInfo "./vault-agent.pid doesn't exist"
        return 1
    fi

    # check if secret file exists
    if [ ! -f /vault-agent/${TARGET_FILE_NAME} ]
    then
        logInfo "/vault-agent/${TARGET_FILE_NAME} doesn't exist"
        return 1
    fi

    # check if currentTime - lastModifiedTime of TARGET_FILE_NAME is >= 30 min (1800 sec) \
    currentTime=`date '+%s'`
    lastModifiedTime=`date -r /vault-agent/${TARGET_FILE_NAME} '+%s'`

    if [ $(($currentTime-$lastModifiedTime)) -gt 1800 ]
    then
        logInfo "agent/.healthcheck is older than 30 minutes"
        return 1
    fi

    return 0
}

if [ checkMidServer ] && [ checkVaultAgent ]
then
    logInfo "Mid server and vault agent are healthy"
    exit 0
else
    logInfo "Mid server or vault agent is unhealthy"
    exit 1
fi