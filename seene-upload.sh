#!/bin/bash

username="$1"
password="$2"

if [ -z "$seene_token" ]
then
	echo "Contact author to learn how to get your authorisation in"
	exit 1
fi

if [ -z "$username" -o -z "$password" ]
then
	echo "usage: $0 username password"
	exit 1
fi

if ! [ -f poster.jpg ]
then
	echo 'Current folder has no poster.jpg, please create it (or get from examples)'
	exit 1
fi

if ! [ -f scene.oemodel ]
then
        echo 'Current folder has no scene.oemodel, please create it (or get from examples)'
        exit 1
fi

caption='#synthetic (Uploaded by https://github.com/neopaf/seene-uploader by @PAF)'
captured_at=$(LANG= date -u +"%Y-%m-%dT%H:%M:%SZ")
dateHeaderValue=$(LANG= date +"%a, %d %b %Y %T %z")

function api_request {
method="$1"; shift
url="$1"; shift
curl -# \
	"$url" \
	-X "$method" \
	-H "Authorization:     Seene api=$seene_token,user=$user_token" \
	-H 'Accept:            application/vnd.seene.co; version=3,application/json' \
	"$@"
}

function amazon_upload {
dir="$1"
file="$2"
content_type="$3"
resource="/$bucket_name/$dir/$file"
stringToSign="PUT\n\n${content_type}\n${dateHeaderValue}\nx-amz-acl:public-read\nx-amz-security-token:$session_token\n${resource}"
signature=`echo -en "$stringToSign" | openssl sha1 -hmac "$secret_access_key" -binary | base64`
curl -# -X PUT -T "${file}" \
	-H "Host: $bucket_name.s3.amazonaws.com" \
	-H "Authorization: AWS ${access_key_id}:${signature}" \
	-H "x-amz-acl: public-read" \
	-H "x-amz-security-token: $session_token" \
	-H "Date: ${dateHeaderValue}" \
	-H "Content-Type: $content_type" \
	"https://$bucket_name.s3.amazonaws.com/$dir/$file"
}

user_token='(null)'
api_request POST https://oecamera.herokuapp.com/api/users/authenticate \
	--form username="$username" \
	--form password="$password" > auth.json

user_token=$(cat auth.json | jq -r .api_token)

request_id=`uuidgen|tr "[A-Z]" "[a-z]"`
echo 'creating entry'
api_request POST https://oecamera.herokuapp.com/api/scenes \
	--form caption="$caption" \
	--form captured_at="$captured_at" \
	--form filter_code=none \
	--form flash_level=0 \
	--form identifier="$scene_id" \
	--form orientation=0 \
	--form shared=0 \
	--form storage_version=3 > entry.json

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
api_request PATCH https://oecamera.herokuapp.com/api/scenes/$scene_id \
	--form finalize=1 > exit.json

cat exit.json | jq -r '[.short_url, .state, "(was uploaded but is private now)"]|join(" ")'
