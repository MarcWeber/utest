#!/bin/sh

set -e

INFO(){ echo "==> INFO : $@"; }
WARNING(){ echo "! ==> WARNING : $@"; }

# TODO add flash
DEFAULT_TARGETS="php neko cpp js-spidermonkey js-browser"

usage(){
  cat << EOF
  usage $0:
  $0 -h | --help : show this help
  $0             : run test on all targets
  $0 php neko    : run test suite on targets php neko only
  --kr | --keep-running : don't stop on failure

  valid targets: $DEFAULT_TARGETS

  choose a php version:
  PHP=/usr/lib/php5/bin/php $0 -php
  BROWSER="opera --new-window URL" $0 -php

  eg $0 js-browser opera
  eg $0 js-browser firefox
EOF
}

for arg in $@; do
  case "$arg" in
    -h|--help)
      usage
    ;;
    --kr|--keep-running)
      KEEP_RUNNING=1
    ;;
    php|neko|cpp|js-sidermonkey|js-browser)
      TARGETS="$TARGETS $arg"
    ;;
    opera)
      WARNING "opera can't cope with nekotools server timestamps. You have to reload the file manually using F5 once!"
      BROWSER="opera -newwindow URL"
    ;;
    firefox)
      BROWSER="firefox -new-window URL"
    ;;
    *)
      echo "! >> unexpected arg: $arg, usage:";
      echo
      usage
      exit 1
  esac
done

TARGETS=${TARGETS:-$DEFAULT_TARGETS}
PHP=${PHP:-php}
KEEP_RUNNING=${KEEP_RUNNING:-}
# BROWSER="opera -newwindow URL"
# BROWSER="firefox -new-window URL"
# ...?
BROWSER=${BROWSER:-opera -newwindow URL}

RUN(){

  local type=$1; shift
  local log=${type}.log
  if eval "$@" &> $log; then
    echo "... $type ok"
  else
    echo "... $type failed. See $log"
    [ -n "$KEEP_RUNNING" ] || {
      cat $log
      exit 1
    }
  fi
  
}

# should create different runs for different php versions ?
test_php(){
  rm -fr php || true
  haxe test-php.hxml
  RUN php "$PHP php/Test.php"
}

# run JS tests in spidermonkey command line tool
test_js_spidermonkey(){
  # have to patch Boot or such?
  # document is not defined - could be fixed easily
  # but Test.js also tries to instantiate XHR !? (TODO)

  # (ftp://ftp.mozilla.org/pub/mozilla.org/js/js-1.7.0.tar.gz)
  # https://developer.mozilla.org/En/SpiderMonkey/Introduction_to_the_JavaScript_shell
  # there are many options which we could use for profiling and such?
  rm -fr Test.js || true
  haxe test-js-spidermonkey.hxml
  RUN js "js Test.js"
}

# run tests in real browser
test_js_browser(){
  # (ftp://ftp.mozilla.org/pub/mozilla.org/js/js-1.7.0.tar.gz)
  # https://developer.mozilla.org/En/SpiderMonkey/Introduction_to_the_JavaScript_shell
  # there are many options which we could use for profiling and such?

  # cleanup:
  rm -fr Test.js || true

  haxe test-js-browser.hxml

  # prepare server and run suite:
  (
    cd test-js-browser
    rm result.txt || true
    haxe server.hxml
    cp ../Test.js .

    # start server
    nekotools server &
    process=$(jobs -p %1)

    url="http://l:2000/index.html"

    # start test:
    eval "${BROWSER/URL/$url} "
    
    while [ ! -e result.txt ]; do
      echo "waiting for result.txt"
      sleep 1
    done
  )

  if [ "$(head -n 1 test-js-browser/result.txt)" == "0" ]; then
    RUN js true
  else
    RUN js "cat test-js-browser/result.txt; false"
  fi
}

test_neko(){
  rm -fr Test.n || true
  haxe test-neko.hxml
  RUN neko neko Test.n
}

for target in $TARGETS; do
  INFO  "testing $target"
  eval "test_${target/-/_}"
done
