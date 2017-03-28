#!/bin/bash

set -euo pipefail

function configureTravis {
  mkdir ~/.local
  curl -sSL https://github.com/SonarSource/travis-utils/tarball/v33 | tar zx --strip-components 1 -C ~/.local
  source ~/.local/bin/install
}
configureTravis
. installJDK8

function strongEcho {
  echo ""
  echo "================ $1 ================="
}
case "$TEST" in

CI)
  strongEcho 'disabled'
  exit 0;
  ;;

plugin|ruling)
  if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
   strongEcho "plugin or ruling tests are only run on pull requests!"
   exit 0;
  fi

  [ "$TEST" = "ruling" ] && git submodule update --init --recursive
  EXTRA_PARAMS=
  [ -n "${PROJECT:-}" ] && EXTRA_PARAMS="-DfailIfNoTests=false -Dtest=JavaRulingTest#$PROJECT"
  strongEcho 'mvn version'
  mvn -version
  strongEcho 'MAVEN_OPTS'
  echo $MAVEN_OPTS
  strongEcho 'RULING JBOSS EJB3'
  mvn install -Dsonar.runtimeVersion="$SQ_VERSION" -Dmaven.test.redirectTestOutputToFile=false -B -e -V -Pit-$TEST $EXTRA_PARAMS
  ;;

*)
  echo "Unexpected TEST mode: $TEST"
  exit 1
  ;;

esac
