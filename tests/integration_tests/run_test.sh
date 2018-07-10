#!/bin/bash
point=$1
if [ "$TRAVIS_EVENT_TYPE" == "cron" ] || [ "$TRAVIS_EVENT_TYPE" == "api" ]
 then
   if [ "$point" == "before" ]
    then
      echo "Before running tests"
      pip3 install -r tests/requirements.txt
      pip3 install client/py-client/.
      pip3 install git+https://github.com/gigforks/packet-python.git
      cd tests/integration_tests; python3 -u packet_install.py create ${packet_token}  ${zrobot_branch} ${TRAVIS_PULL_REQUEST_BRANCH}
   elif [ "$point" == "run" ]
    then
      echo "Running tests .."
      echo "[+] Copying testing framework  ..."
      cd tests/integration_tests
      bash prepare.sh
      echo "[+] Connecting to 0-robot server ..."
      machine_ip=$(cat /tmp/ip.txt)

      echo "server ip ${machine_ip} ..."
      sleep 100
      zrobot robot connect main http://${machine_ip}:6600; sleep 20
      echo "[+] Running tests ..."
      nosetests -v -s ${tests_path} --tc-file=config.ini
   elif [ "$point" == "after" ]
    then
      cd tests/integration_tests; python3 packet_install.py delete $PACKET_TOKEN
   fi
 else
   echo "Not a cron job"
fi
