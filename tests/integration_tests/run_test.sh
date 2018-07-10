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
      cd tests/integration_tests; python3 -u packet_install.py create $PACKET_TOKEN $TRAVIS_BRANCH $TRAVIS_PULL_REQUEST_BRANCH
   elif [ "$point" == "run" ]
    then
      echo "Running tests .."
      echo "[+] Copying testing framework ..."
      cd tests/integration_tests
      bash prepare.sh
      cd tests; nosetests -v -s testsuite
      echo "[+] Connecting to 0-robot server ..."
      config = configparser.ConfigParser()
      config.read('config.ini')
      machine_ip=config['main']['target_ip']
      zrobot robot connect main http://${machine_ip}:6600; sleep 20
      echo "[+] Running tests ..."
      nosetests -v -s ${tests_path} --tc-file=config.ini
   elif [ "$point" == "after" ]
    then
      cd tests/integration_tests; python3 packet_script.py delete $PACKET_TOKEN
   fi
 else
   echo "Not a cron job"
fi
