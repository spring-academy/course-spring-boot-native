#!/bin/bash

RELEASE_FILE=bellsoft-liberica-vm-core-openjdk17.0.7+7-23.0.0+1-linux-amd64.tar.gz
curl -o $RELEASE_FILE https://download.bell-sw.com/vm/23.0.0/$RELEASE_FILE

tar xzf $RELEASE_FILE
rm $RELEASE_FILE

UNTARRED_DIR=bellsoft-liberica-vm-core-openjdk17-23.0.0
INSTALLED_DIR="/opt/$UNTARRED_DIR"

mv "$UNTARRED_DIR" "$INSTALLED_DIR"

# TODO Is there a better way to set env vars in the eduk8s user's profile than writing directly to .bashrc?
# Other than doing it in the workshopl.yaml because here is where we know what the values are.
cat >> "$HOME/.bashrc" <<EOF

# GraalVM
export JAVA_HOME="$INSTALLED_DIR"
# Put GraalVM first in PATH, to override bash image's java
export PATH="$INSTALLED_DIR/bin:$PATH"
EOF

unset INSTALLED_DIR
unset UNTARRED_DIR
unset RELEASE_FILE
