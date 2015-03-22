#!/bin/bash

function api_request {
method="$1"
url="$2"
data="$3"
curl -# \
"$url" \
-X "$method" \
-H "Authorization:     $AUTHORIZATION" \
-H 'Accept:            application/vnd.seene.co; version=3,application/json' \
-d "$data"
}

function amazon_upload {
dir="$1"
file="$2"
content_type="$3"
resource="/$bucket_name/$dir/$file"
dateValue=$(LANG= date +"%a, %d %b %Y %T %z")
stringToSign="PUT\n\n${content_type}\n${dateValue}\nx-amz-acl:public-read\nx-amz-security-token:$session_token\n${resource}"
signature=`echo -en "$stringToSign" | openssl sha1 -hmac "$secret_access_key" -binary | base64`
curl -# -X PUT -T "${file}" \
  -H "Host: $bucket_name.s3.amazonaws.com" \
  -H "Authorization: AWS ${access_key_id}:${signature}" \
  -H "x-amz-acl: public-read" \
  -H "x-amz-security-token: $session_token" \
  -H "Date: ${dateValue}" \
  -H "Content-Type: $content_type" \
  "https://$bucket_name.s3.amazonaws.com/$dir/$file"
}

request_id=`uuidgen|tr "[A-Z]" "[a-z]"`
caption='Test5'
captured_at='2015-03-22T23%3A47%3A43Z'

echo 'creating entry'
api_request POST https://oecamera.herokuapp.com/api/scenes "caption=$caption&captured_at=$captured_at&filter_code=none&flash_level=0&identifier=$scene_id&latitude&location&longitude&orientation=0&shared=0&storage_version=3" > entry.json

access_key_id=$(cat entry.json|jq -r .meta.access_key_id)
bucket_name=$(cat entry.json|jq -r .meta.bucket_name)
model_dir=$(cat entry.json|jq -r .meta.model_dir)
poster_dir=$(cat entry.json|jq -r .meta.poster_dir)
session_token=$(cat entry.json|jq -r .meta.session_token)
secret_access_key=$(cat entry.json|jq -r .meta.secret_access_key)

echo 'uploading model'
amazon_upload "$model_dir" scene.oemodel application/octet-stream
echo 'uploading image'
amazon_upload "$poster_dir" poster.jpg image/jpeg

#not to depend on above code, while debugging I comment it out often
scene_id=$(cat entry.json|jq -r .scene.identifier)
echo 'finalizing'
api_request PATCH https://oecamera.herokuapp.com/api/scenes/$scene_id "caption=$caption&captured_at=$captured_at&filter_code=none&finalize=1&flash_level=0&identifier=$scene_id&latitude&location&longitude&orientation=0&shared=0&storage_version=3"

