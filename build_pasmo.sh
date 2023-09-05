#!/bin/sh

BUILD_DIR="../build"
ASSETS_DIR="../assets"
SRC_DIR="./src"

echo ""
echo "---------- COMPILING -------------"
echo "Output Filename: " $1

pwd
cd $SRC_DIR
pwd
pasmo --name $1 --tap main.asm $BUILD_DIR/output.tap 
cat $ASSETS_DIR/loader.tap $ASSETS_DIR/pong-scr.tap $BUILD_DIR/output.tap > $BUILD_DIR/$1.tap