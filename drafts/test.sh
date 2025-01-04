#!/bin/bash
# Minimal OS detection
OSTYPE=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$OSTYPE" in
  linux*)   OSTYPE="linux-gnu" ;;
  darwin*)  OSTYPE="darwin" ;;
  bsd*)     OSTYPE="bsd" ;;
  msys*)    OSTYPE="msys" ;;
  cygwin*)  OSTYPE="cygwin" ;;
  *)        OSTYPE="unknown" ;;
esac
echo "Detected OS: $OSTYPE"
exit;
