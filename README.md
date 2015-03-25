## About
http://seene.co/ uploader 

See some of results: http://seene.co/search/seenes/?q=synthetic

TODO: AUTHORIZATION PART IS NOT READY YET, CONTACT ME IF YOU WANT TO FIND OUT seene_token.
Still hesitating if it's allright just to publish it.

## Usage
Create your model (scene.oemodel + poster.jpg). 

sceene.oemodel should be in special format, there is no publicly available authoring tool for that (yet), so
* at first use some from provided examples/, then
* either use one of backed up (see https://github.com/neopaf/seene-uploader)
* or programmatically create one (see Useful links section below for source code of decoder; based on which it is not hard to create an encoder)

Put them next to script

`./seene-upload.sh your_seene_nick`

Creates a private seene.

Go to your seene app (not web), open your Seenes, Private section. Enjoy.
## Prerequisite
jq binary in your path, http://stedolan.github.io/jq/
## Disclaimer
Tested on my Mac.
Should be easily ported to Windows.

Yours truly,
Alexander Petrossian (PAF), Moscow, Russia
##Useful links
###SeeneLib library for Processing
If you'll decide someday to see what you've got, so far the best is

https://github.com/BenVanCitters/SeeneLib---Processing-Library
###Small JavaScript model renderer (no texture)
https://github.com/detunized/seene-viewer
##Thanks
To Creators of Seene app.

To jq author.

To mitmproxy authors.
## Example output
```
macMini:seene-uploader paf$ . auth.sh #not published, todo: replace with autokeydiscovery
macMini:seene-uploader paf$ ./seene-upload.sh
creating entry
######################################################################## 100,0%
uploading model
uploading image
finalizing
######################################################################## 100,0%
http://seene.co/s/iV1C6Z ready (was uploaded but is private now)
macMini:seene-uploader paf$ 
```
