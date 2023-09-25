#!/bin/bash

logInfo () {
  msg="[entrypoint script] $(date '+%Y-%m-%dT%T.%3N') ${1}"
  echo "$msg" | tee -a ${LOG_FILE}
}


sed -i '1816 i echo "${COMMAND_LINE}"' /opt/snc_mid_server/agent/bin/mid.sh

if [ "${CHECK_MODE}" == "true" ] || [ "${CHECK_MODE}" == "TRUE" ] ;
    then
        logInfo "CHECK_MODE is set to true. Waiting ..." && tail -f /dev/null ;
    else
        # start vault agent   # start mid server
        logInfo "CHECK_MODE is set to false. Starting vault agent and mid server" && (/vault-agent/init & /opt/snc_mid_server/init start) ;
fi

