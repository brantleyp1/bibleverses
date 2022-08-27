# Bible verses
Quickly grab and format one or many verses 

## Purpose

This script should be able to grab a verse or many from biblehub.com, then either print it to a file, or to standard out. 

## Synopsis

I record the sermon weekly for a local church and edit the video for the web. I do a lower-thirds of the verses during the video, and some weeks there are more verses than others. The week there were 30+ verses, rather than copying and pasting each verse, I wrote this script to go get the verses, then add them to a cheatsheet I use each week to fill out all the various fields for the video.

The script pulls the text(s), then formats according to my setup. AFor instance I need the lines to not be longer than roughly 72 columns, but I cannot have more than 4 lines per lower-thirds slide because of how they're designed. So I have a little logic that if the total number of characters is say over 150, it breaks the line at around 60, but if there are 250 characters it breaks at 70, but always tries to break on a punctuation mark.

But then I got to thinking that maybe it would be nice if this could also quickly grab a verse/passage and just print it to standard out, so that's in there too.

## Getting this script

If you're familiar with Git, clone the repo and then `chmod +x bibleverses.sh` to make it executable.

If you are not familiar with Git:

The easiest way is to click on the raw button on the upper right of the file panel, then copy the text and paste it into a file on your computer. This script is written for Bash, so you'll need either a Mac, Linux, or a PC with Cygwin installed in order to run.

Steps:
1. Click the raw button
2. Copy the text
3. With your favorite text editor, open a new file, paste in the text you copied
4. Save the file as bibleverses.sh
5. Open a command prompt (terminal on Mac)
6. Go to the folder where the file you just created is
7. Run `chmod +x bibleverses.sh` to make it executable
8. Then run the script (see Examples below).

## Examples

Basic example to return a verse to standard out:
```
./bibleverses.sh Matthew 22:36-40
``` 

You can specify a translation:
```
./bibleverses.sh 1 cor 13:12 NIV
``` 

To add text to a particular file:
```
./bibleverses.sh /path/to/file
``` 

To add text to the default file:
```
./bibleverses.sh
``` 
 
## About the file feature

I added a sample file named `verses` that is what the script looks for, but the file name can be changed in the script. 

The file method is pretty particular to my needs, I enter all the passages in order to create a screen at the beginning of the video with all of "today's" scripture, then add and format the text for the video. The file has a couple of tags that it needs to find the text to look up, and then to print the text back to the file. 

To find the needed chapter/verses it looks for a tag `### scripturelist` then a list of verses immediately following, i.e.:
```
### scripturelist
Today's Scripture (ESV)
Psalm 23:1-6
Genesis 1:26
```

The `Todays's Scripture (ESV)` is not required, but if found it will set the default translation for this run. The parenthesis `()` are required in order to find a translation.

Then it looks for `### scripturewritten` to insert the text after. If not found the script will not insert text.

The rest was just leftover from how I use this file and script for my church needs, YMMV.

## Options

The /path/to/file is actually not required, if you always have the same file in the same location that you would like to add the text to, edit the script and set it to the customizable options:
```
### User adjustable options:
# file name and path variables for use with file method if you always want to update a particular file
file_name=verses
file_path=~/Desktop/church
```

Other adjustable options are the default translation (Default is ESV) and the max width when going into a file (default 74).

The three ways to run are:
`./bibleverses.sh john 3:16` to retrieve text to standard out
`./bibleverses.sh /some/path/to/file` to retrieve text and add it to the file listed
`./bibleverses.sh` to retrieve text and add it to the default file listed in the script

There is a help function that you can call either by running `./bibleverses.sh help`, or with the `-h` or `--help` flags.


## Notes

The translations are limited to what biblehub.com offers. 

There are around 30 English translations on their site, including:
NIV
NLT
ESV
KJV
NKJV
WEB

I have not tested any other languages other than English, if you run into any trouble let me know. I may not be able to, but I'd love to help.
