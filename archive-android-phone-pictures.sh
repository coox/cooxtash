#!/usr/bin/env zsh

SOURCE_ANDROID_PHONE_ROOT_PATH=""
DESTINATION_PATH=""

usage() {
  echo "Usage: ./$0 -s SOURCE_ANDROID_PHONE_ROOT_PATH -d DESTINATION_PATH"
}

while getopts ":d:s:" opt; do
  case $opt in
    d) DESTINATION_PATH="${OPTARG}" ;;
    s) SOURCE_ANDROID_PHONE_ROOT_PATH="${OPTARG}" ;;
    \?) echo "Illegal option -${OPTARG}" >&2 ; usage ; exit 2 ;;
  esac
done

if [ ! -d "${SOURCE_ANDROID_PHONE_ROOT_PATH}" ]
then
  echo "Source Android phone root path \"${SOURCE_ANDROID_PHONE_ROOT_PATH}\" is not a directory" >&2
  usage
  exit 2
fi

if [ ! -d "${DESTINATION_PATH}" ]
then
  echo "Destination path \"${DESTINATION_PATH}\" is not a directory" >&2
  usage
  exit 2
fi

# Default macOS `rsync` does not support `--iconv` option
# Therefore, use Homebrew-provided `rsync` to benefit `--iconv=utf-8-mac,utf-8`
# https://askubuntu.com/a/540960
RSYNC=/usr/local/bin/rsync

# Move files from Camera
$RSYNC -av --remove-source-files "${SOURCE_ANDROID_PHONE_ROOT_PATH}/DCIM/100ANDRO/" "${DESTINATION_PATH}"
$RSYNC -av --remove-source-files "${SOURCE_ANDROID_PHONE_ROOT_PATH}/DCIM/Camera/" "${DESTINATION_PATH}"
$RSYNC -av --remove-source-files "${SOURCE_ANDROID_PHONE_ROOT_PATH}/DCIM/XPERIA/BURST/" "${DESTINATION_PATH}" && find "${SOURCE_ANDROID_PHONE_ROOT_PATH}/DCIM/XPERIA/BURST/" -type d -delete
$RSYNC -av --remove-source-files "${SOURCE_ANDROID_PHONE_ROOT_PATH}/DCIM/XPERIA/PREDICTIVE_CAPTURE/" "${DESTINATION_PATH}" && find "${SOURCE_ANDROID_PHONE_ROOT_PATH}/DCIM/XPERIA/PREDICTIVE_CAPTURE/" -type d -delete

# Move files from Screenshots
$RSYNC -av --remove-source-files "${SOURCE_ANDROID_PHONE_ROOT_PATH}/Pictures/Screenshots/" "${DESTINATION_PATH}"

# Move files from Instagram
$RSYNC -av --remove-source-files "${SOURCE_ANDROID_PHONE_ROOT_PATH}/Pictures/Instagram/" "${DESTINATION_PATH}"

# Move files from Android Messages
$RSYNC -av --remove-source-files "${SOURCE_ANDROID_PHONE_ROOT_PATH}/Pictures/Messages/" "${DESTINATION_PATH}"

# Move files from Facebook Messenger
$RSYNC -av --remove-source-files "${SOURCE_ANDROID_PHONE_ROOT_PATH}/Pictures/Messenger/" "${DESTINATION_PATH}"

# Move files from Telegram
$RSYNC -av --remove-source-files "${SOURCE_ANDROID_PHONE_ROOT_PATH}/Telegram/Telegram Audio/" "${DESTINATION_PATH}"
$RSYNC -av --remove-source-files "${SOURCE_ANDROID_PHONE_ROOT_PATH}/Telegram/Telegram Documents/" "${DESTINATION_PATH}"
$RSYNC -av --remove-source-files "${SOURCE_ANDROID_PHONE_ROOT_PATH}/Telegram/Telegram Images/" "${DESTINATION_PATH}"
$RSYNC -av --remove-source-files "${SOURCE_ANDROID_PHONE_ROOT_PATH}/Telegram/Telegram Video/" "${DESTINATION_PATH}"

# Move files from Twitter
$RSYNC -av --remove-source-files "${SOURCE_ANDROID_PHONE_ROOT_PATH}/Pictures/Twitter/" "${DESTINATION_PATH}"

# Move files from WhatsApp, flattening directory structure
# (ie. the files within “Sent” and “Private” directories are copied, but the directories themselves are not preserved)
for SOURCE_WHATSAPP_DIR in \
  "${SOURCE_ANDROID_PHONE_ROOT_PATH}/WhatsApp/Media/WhatsApp Animated Gifs" \
  "${SOURCE_ANDROID_PHONE_ROOT_PATH}/WhatsApp/Media/WhatsApp Audio" \
  "${SOURCE_ANDROID_PHONE_ROOT_PATH}/WhatsApp/Media/WhatsApp Documents" \
  "${SOURCE_ANDROID_PHONE_ROOT_PATH}/WhatsApp/Media/WhatsApp Images" \
  "${SOURCE_ANDROID_PHONE_ROOT_PATH}/WhatsApp/Media/WhatsApp Profile Photos" \
  "${SOURCE_ANDROID_PHONE_ROOT_PATH}/WhatsApp/Media/WhatsApp Stickers" \
  "${SOURCE_ANDROID_PHONE_ROOT_PATH}/WhatsApp/Media/WhatsApp Video" \
  "${SOURCE_ANDROID_PHONE_ROOT_PATH}/WhatsApp/Media/WhatsApp Voice Notes"
do
  cd "${SOURCE_WHATSAPP_DIR}"
  find . -type f | $RSYNC -av --iconv=utf-8-mac,utf-8 --files-from - --remove-source-files --no-relative . ${DESTINATION_PATH}
done

# Mandatory success message with emoji
echo "✨ Done."
