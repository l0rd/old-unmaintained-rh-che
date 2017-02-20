#!/bin/sh
set -e

export CHE_LOCAL_GIT_REPO=${CHE_LOCAL_GIT_REPO:-~/github/che}
export PLUGIN_FOLDER=./plugin-files
export PATCHES_FOLDER=./patches

if [ ! -d "$CHE_LOCAL_GIT_REPO" ]; then
  echo "Folder \"$CHE_LOCAL_GIT_REPO\" (CHE_LOCAL_GIT_REPO) does not exist"
  exit 1
fi

apply_patch() {
  FILE_PATH=$1
  PATCH_FILE_PATH=$PATCHES_FOLDER/$2
  ORIG_FILE_PATH=$CHE_LOCAL_GIT_REPO/$FILE_PATH
  echo "Patch $FILE_PATH"
  patch --quiet --dry-run $ORIG_FILE_PATH $PATCH_FILE_PATH
  patch --quiet $ORIG_FILE_PATH $PATCH_FILE_PATH
}

generate_patch_file() {
  FILE_PATH=$1
  PATCH_FILE_PATH=$PATCHES_FOLDER/$2
  ORIG_FILE_PATH=$CHE_LOCAL_GIT_REPO/$FILE_PATH
  MOD_FILE_PATH=$PLUGIN_FOLDER/$FILE_PATH
  echo "Generate $PATCH_FILE_PATH"
  diff -u  --label=original --label=modified $ORIG_FILE_PATH $MOD_FILE_PATH > $PATCH_FILE_PATH || true
}

process_file() {
  FILE_PATH=$1
  PATCH_FILE_NAME=$2
  # Use 
  #  - `apply_patch $FILE_PATH $PATCH_FILE_NAME` to patch Che 
  #  - `generate_patch_file $FILE_PATH $PATCH_FILE_NAME` to generate patches
  #apply_patch $FILE_PATH $PATCH_FILE_NAME
  generate_patch_file $FILE_PATH $PATCH_FILE_NAME
}

# Copy plugin-bayesian-lsp folder
echo "Copy plugin-bayesian-lsp folder"
cp -R $PLUGIN_FOLDER/plugins/plugin-bayesian-lsp $CHE_LOCAL_GIT_REPO/plugins/plugin-bayesian-lsp

# Copy agents/ls-bayesian folder
echo "Copy agents/ls-bayesian folder"
SRC_FILE=$PLUGIN_FOLDER/agents/ls-bayesian/
DEST_FOLDER=$CHE_LOCAL_GIT_REPO/agents/
cp -R $PLUGIN_FOLDER/agents/ls-bayesian $CHE_LOCAL_GIT_REPO/agents/ls-bayesian

# Patch plugins pom.xml
FILE_PATH=plugins/pom.xml
PATCH_FILE_NAME=plugins_pom.patch
process_file $FILE_PATH $PATCH_FILE_NAME 

# Patch agents pom.xml
FILE_PATH=agents/pom.xml
PATCH_FILE_NAME=agents_pom.patch
process_file $FILE_PATH $PATCH_FILE_NAME 

# Patch assembly/assembly-wsagent-war/pom.xml
PATCH_FILE_NAME=assembly-wsagent-war_pom.patch
FILE_PATH=assembly/assembly-wsagent-war/pom.xml
process_file $FILE_PATH $PATCH_FILE_NAME 

# Patch assembly/assembly-wsmaster-war/pom.xml
PATCH_FILE_NAME=assembly-wsmaster-war_pom.patch
FILE_PATH=assembly/assembly-wsmaster-war/pom.xml
process_file $FILE_PATH $PATCH_FILE_NAME 

# Patch assembly/assembly-wsmaster-war/src/main/java/org/eclipse/che/api/deploy/WsMasterModule.java
PATCH_FILE_NAME=WsMasterModule.patch
FILE_PATH=assembly/assembly-wsmaster-war/src/main/java/org/eclipse/che/api/deploy/WsMasterModule.java
process_file $FILE_PATH $PATCH_FILE_NAME 

# Patch root pom.xml
PATCH_FILE_NAME=root_pom.patch
FILE_PATH=pom.xml
process_file $FILE_PATH $PATCH_FILE_NAME

echo "Done!"