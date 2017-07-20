#!/bin/bash

set -e

if [[ -n "${MMW_MICRO_DEBUG}" ]]; then
    set -x
fi

# Default settings
SOURCE_ROOT="./src/app/"
DIST_ROOT="./dist/"
BIN="${SOURCE_ROOT}node_modules/.bin"

STATIC_JS_DIR="${DIST_ROOT}js/"
STATIC_CSS_DIR="${DIST_ROOT}css/"
STATIC_IMAGES_DIR="${DIST_ROOT}img/"
STATIC_FONTS_DIR="${DIST_ROOT}fonts/"
STATIC_DATA_DIR="${DIST_ROOT}data/"

BROWSERIFY="$BIN/browserify"
ENTRY_JS_FILES="${SOURCE_ROOT}js/src/main.js"

MINIFY_PLUGIN="-p [ ./src/app/node_modules/minifyify --no-map ]"

NODE_SASS="$BIN/node-sass"
ENTRY_SASS_DIR="${SOURCE_ROOT}sass/"
ENTRY_SASS_FILE="${ENTRY_SASS_DIR}main.scss"
VENDOR_CSS_FILE="${STATIC_CSS_DIR}vendor.css"

usage() {
    echo -n "$(basename "${0}") [OPTION]...

Bundle JS and CSS static assets.

 Options:
  --watch      Listen for file changes
  --debug      Generate source maps
  --production Minify bundles (**SLOW**); Disables source maps
  --list       List browserify dependencies
  --vendor     Generate vendor bundle and copy assets
  -h, --help   Display this help text
"
}

# Handle options
while [[ -n $1 ]]; do
    case $1 in
        --watch)      ENABLE_WATCH=1 ;;
        --debug)      ENABLE_DEBUG=1 ;;
        --production) ENABLE_MINIFY=1 ;;
        --list)       LIST_DEPS=1 ;;
        -h|--help|*)  usage; exit 1 ;;
    esac
    shift
done

if [ -n "$ENABLE_WATCH" ]; then
    BROWSERIFY="$BIN/watchify"
    # These flags have to appear last or watchify will exit immediately.
    EXTRA_ARGS="--verbose --poll"
    NODE_SASS="$NODE_SASS --watch --recursive"
    # This argument must be a folder in watch mode, but a
    # single file otherwise.
    ENTRY_SASS_FILE="$ENTRY_SASS_DIR"
fi

if [ -n "$ENABLE_DEBUG" ]; then
    BROWSERIFY="$BROWSERIFY --debug"
    NODE_SASS="$NODE_SASS --source-map true --source-map-embed"
fi

if [ -n "$ENABLE_MINIFY" ]; then
    EXTRA_ARGS="$MINIFY_PLUGIN $EXTRA_ARGS"
fi

if [ -n "$LIST_DEPS" ]; then
    BROWSERIFY="$BROWSERIFY --list"
fi

COPY_IMAGES_COMMAND="cp -r \
    ${SOURCE_ROOT}img/* \
    $STATIC_IMAGES_DIR"

COPY_FONTS_COMMAND="cp -r \
    ${SOURCE_ROOT}node_modules/font-awesome/fonts/* \
    $STATIC_FONTS_DIR"

CONCAT_VENDOR_CSS_COMMAND="cat \
    ${SOURCE_ROOT}node_modules/font-awesome/css/font-awesome.min.css \
    > $VENDOR_CSS_FILE"

COPY_DATA_COMMAND="cp \
    ${SOURCE_ROOT}data/model.csv \
    ${STATIC_DATA_DIR}model.csv"

COPY_INDEX_COMMAND="cp \
    ${SOURCE_ROOT}index.html \
    ${DIST_ROOT}index.html"

COPY_FAVICON_COMMAND="cp \
    ${SOURCE_ROOT}img/favicon*.png \
    ${DIST_ROOT}"

JS_DEPS=(jquery
         bootstrap
         retina.js
         underscore)

BROWSERIFY_EXT=""
BROWSERIFY_REQ=""
for DEP in "${JS_DEPS[@]}"
do
    BROWSERIFY_EXT+="-x ./src/app/node_modules/$DEP -r ./src/app/js/shim/shutterbug.js "
    BROWSERIFY_REQ+="-r ./src/app/node_modules/$DEP -r ./src/app/js/shim/shutterbug.js "
done

VENDOR_COMMAND="
    $COPY_IMAGES_COMMAND &
    $COPY_FONTS_COMMAND &
    $CONCAT_VENDOR_CSS_COMMAND &
    $COPY_DATA_COMMAND &
    $COPY_FAVICON_COMMAND &
    $BROWSERIFY $BROWSERIFY_REQ \
        -o ${STATIC_JS_DIR}vendor.js $EXTRA_ARGS &"

VAGRANT_COMMAND="cd ${SOURCE_ROOT} &
    $COPY_INDEX_COMMAND &
    $VENDOR_COMMAND
    $NODE_SASS $ENTRY_SASS_FILE -o ${STATIC_CSS_DIR} &
    $BROWSERIFY $ENTRY_JS_FILES $BROWSERIFY_EXT \
        -o ${STATIC_JS_DIR}main.js $EXTRA_ARGS &"

# Clear out distribution root before build.
rm -rf $DIST_ROOT*

# Ensure static asset folders exist.
mkdir -p \
    $STATIC_JS_DIR \
    $STATIC_CSS_DIR \
    $STATIC_IMAGES_DIR \
    $STATIC_FONTS_DIR \
    $STATIC_DATA_DIR

echo "$VAGRANT_COMMAND"
eval "$VAGRANT_COMMAND"

if [ -z "$ENABLE_WATCH" ]; then
    echo "Waiting for background jobs to finish..."
    wait
    echo "Done"
fi
