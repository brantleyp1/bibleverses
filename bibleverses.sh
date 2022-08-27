#! /bin/bash 
#set -x

### User adjustable options:
# file name and path variables for use with file method if you always want to update a particular file
file_name=verses
file_path=~/Desktop/btc

# setting the width of columns for video editing, around 76-80 is too much for a lower thirds in AfterEffects but YMMV
max_width=74

# setting default translation for cli version, file version takes from "today's scripture" in file
default_trans="esv"


### end of user adjustable options

# to run standalone or not
verse_file=""

# help text
    helptext="
Usage:
	
	$0
			- This will look for a file named \"${file_name}\" at \"${file_path}\" and will look for a list of verses/passages and print the text(s) back to the file. 

	$0  /some/path/to/a/file
			- This will look at the path you supplied and make sure a file exists, and will print the verse(s) back to that file.

	$0  John 3:16 niv
			- This will look for the verse and print to screen, version is optional.

	$0  1John 3:16-18
			- This will look for the passage range and print to screen, version is optional.

	$0  help
			- Print this help and more information on using the file method
"

additional_help="\
The Book name (i.e. John) does not have to be capitalized and this script will attempt to fix spelling errors, within reason. The only versions supported are what are available on Biblehub.com.

For the file method to work, a file named ${file_name} must be present either at ${file_path} or supplied at the command line. This setting can be changed in the options. For standard output method this doesn't apply.

The script will look for the scripturelist marker, then will find the passages in the list below. The translation isn't required but if desired must be in \`()'. The line with Today's Scripture isn't required, but if not present the script will assume ESV for the default version unless set per passage requested. The default translation can be set in the options.

Excerpt of the file below. Expects \`scripturelist' and \`scripturewritten' to be present, with a list of verses immediately below \`scripturelist': "

example_text="
---------EXAMPLE------------------

### scripturelist
Today's Scripture (ESV):
Psalm 23:1-6 (NIV)


### scripturewritten

---------EXAMPLE------------------
"

if [[ "$@" == *"-h"* ]] || [[ "$@" == *"-H"* ]] || [[ "$@" == *"-?"* ]]; then
    screen_width=$(tput cols)
    case ${screen_width} in
	[0-9]|[0-9][0-9]) screen_width=$(( ${screen_width} / 2 )) ;;
	[0-9][0-9][0-9]) screen_width=$(( ${screen_width} / 3 )) ;;
    esac
    echo -e "$helptext" | fmt -ns -w ${screen_width}
    exit 0
elif [[ "$@" == "help" ]]; then
    screen_width=$(tput cols)
    case ${screen_width} in
	[0-9]|[0-9][0-9]) screen_width=$(( ${screen_width} / 2 )) ;;
	[0-9][0-9][0-9]) screen_width=$(( ${screen_width} / 3 )) ;;
    esac
    echo -e "$helptext" | fmt -ns -w ${screen_width}
    echo -e "$additional_help" | fmt -ns -w ${screen_width}
    echo "$example_text"
    exit 0
fi

## identify if running against a file or standard input
if [ -n "$1" ] && [ -e "$1" ]; then
	path_to_verses="$1"
	verse_file=TRUE
elif [ -n "$1" ] && [ ! -e "$1" ]; then
	verse_file=FALSE
	verse="$@"
else
	path_to_verses="$(find $file_path -type d -name "$(date -j +%Y)*")/${file_name}"
	verse_file=TRUE
fi

## a couple of functions
function spellchecker {
spellcheck=$(cat << EOT
spellGenesis Genesis genesis/
spellExodus Exodus exodus/
spellLeviticus Leviticus leviticus/
spellNumbers Numbers numbers/
spellDeuteronomy Deuteronomy dut Dut deut Deut/
spellJoshua Joshua joshua/
spellJudges Judges judges/
spellRuth Ruth ruth/
spellSamuel Samuel sam Sam samuel/
spell1_Samuel 1_Samuel 1sam 1Sam 1Samuel 1samuel/
spell2_Samuel 2_Samuel 2sam 2Sam 2Samuel 2samuel/
spellKings Kings kings/
spell1_Kings 1_Kings 1kings 1Kings/
spell2_Kings 2_Kings 2kings 2Kings/
spellChronicles Chronicles chronicles/
spell1_Chronicles 1_Chronicles 1chronicles 1Chronicles 1chronicals 1Chronicals/
spell2_Chronicles 2_Chronicles 2chronicles 2Chronicles 2chronicals 2Chronicals/
spellEzra Ezra ezra/
spellNehemiah Nehemiah neamiah nehemiah/
spellEsther Esther ester Ester esther/
spellJob Job job/
spellPsalms Psalms psalms psalm Psalm/
spellProverbs Proverbs proverbs/
spellEcclesiastes Ecclesiastes ecc Ecc/
spellSong Song song solomon songs Songs/
spellIsaiah Isaiah isaiah isa Isa/
spellJeremiah Jeremiah jerimiah jeremiah jeri/
spellLamentations Lamentations lamentations/
spellEzekiel Ezekiel exekiel/
spellDaniel Daniel daniel/
spellHosea Hosea hosea/
spellJoel Joel joel/
spellAmos Amos amos/
spellObadiah Obadiah obadiah/
spellJonah Jonah jonah/
spellMicah Micah micah/
spellNahum Nahum nahum/
spellHabakkuk Habakkuk habbakuk habakkuk/
spellZephaniah Zephaniah zephaniah/
spellHaggai Haggaia haggaia/
spellZechariah Zechariah zechariah/
spellMalachi Malachi malachi/
spellMatthew Matthew matthew mathew Mathew matt Matt/
spellMark Mark mark/
spellLuke Luke luke/
spellJohn John john/
spellActs Acts acts/
spellRomans Romans romans/
spellCorinthians Corinthians corinthians Cor cor/
spell1_Corinthians 1_Corinthians 1corinthians 1Corinthians 1Cor 1cor/
spell2_Corinthians 2_Corinthians 2corinthians 2Corinthians 2Cor 2cor/
spellGalatians Galatians galatians gal Gal/
spellEphesians Ephesians ephesians/
spellPhilippians Philippians phillipians philipians Phillipians/
spellColossians Colossians colassians/
spellThessalonians Thessalonians thessalonias thes Thes/
spell1_Thessalonians 1_Thessalonians 1thessalonias 1thes 1Thes/
spell2_Thessalonians 2_Thessalonians 2thessalonias 2thes 2Thes/
spellTimothy Timothy timothy tim Tim/
spell1_Timothy 1_Timothy 1timothy 1tim 1Tim/
spell2_Timothy 2_Timothy 2timothy 2tim 2Tim/
spellTitus Titus titus/
spellPhilemon Philemon phil Phil philemon/
spellHebrews Hebrews hebrews/
spellJames James james/
spellPeter Peter peter pet Pet Peter/
spell1_Peter 1_Peter 1peter 1pet 1Pet 1Peter/
spell2_Peter 2_Peter 2peter 2pet 2Pet 2Peter/
spell1_John 1_John 1john 1John/
spell2_John 2_John 2john 2John/
spell3_John 3_John 3john 3John/
spellJude Jude jude/
spellRevelation Revelation rev Rev revelation revelations revalations Revalations/
EOT)

echo ${spellcheck} | awk -v var="${1}" '$0~var' RS='/' | head -1 | awk '{ print $1 }' | cut -c 6-
}

function fmtVerses {
	case "${#verse_text}" in
		[0-3]) echo "Verse #$verse not found" ;;
		[4-9]|[0-9][0-9]|1[0-4][0-9])
			echo ${verse_text} | fmt -ns -w $(( $max_width / 2 + 8 )) -d '.!?,:' | awk '{$1=toupper(substr($1,0,1))substr($1,2)}1' ;;
		1[5-9][0-9]|2[0-9][0-9])
			echo ${verse_text} | fmt -ns -w $(( $max_width / 4 * 3 + 2 )) -d '.!?,:' | awk '{$1=toupper(substr($1,0,1))substr($1,2)}1' ;;
		[3-9][0-9][0-9])
			echo "${verse_text}" | fmt -ns -w ${max_width} -d '.!?,:' | awk '{$1=toupper(substr($1,0,1))substr($1,2)}1' ;;
	esac

}
function getVerses {


while read first second third fourth; do
	## first
	if [[ "$first" =~ [a-zA-Z] ]]; then
		# check spelling of first
		first=$(spellchecker ${first})
		book=$(echo "$first" | tr '[:upper:]' '[:lower:]')
		book_upper="$(echo $first | tr '_' ' ')"
	else
		booknumber="${first}_"
	fi
	## second i.e. psalms 115:16, the 115:16. or john 3:15-17, the 3:15-17. or 1 peter 2:14 the peter
	if [[ "$second" =~ [a-zA-Z] ]]; then
		## the peter
		second=$(spellchecker "${second}")
		book="$booknumber$(echo "$second" | tr '[:upper:]' '[:lower:]')"
		book_upper="$first $second"
	else
		chapterverse=$second
		if [[ "${chapterverse}" == *":"* ]]; then
			chapter=$(echo "${chapterverse}" | awk -F':' '{ print $1 }')

			## the 3:15-17, but only 15-17 or 115:16 but only 16
			verse_all=$(echo "${chapterverse}" | awk -F':' '{ print $2 }')

			#if [[ "$verse_all" == *","* ]]; then
			if [[ "$verse_all" == *"-"* ]]; then
				#verse=$verse_all
				## the 15
				verse_first=$(echo "${verse_all}" | awk -F'-' '{ print $1 }')
				## the 17
				verse_last=$(echo "${verse_all}" | awk -F'-' '{ print $2 }')
				verse_list=$(echo "${verse_last} - ${verse_first} + 1" | bc -l)
			else
				## the 16
				verse="$verse_all"
				verse_list=1
			fi

		elif [[ "${chapterverse}" == *"-"* ]]; then
			#verse="$verse_all"
			verse_first=$(echo "${verse_all}" | awk -F'-' '{ print $1 }')
			verse_last=$(echo "${verse_all}" | awk -F'-' '{ print $2 }')
			verse_list=$(echo "${verse_last} - ${verse_first} + 1" | bc -l)
		else
			verse_list=1
			#verse_list=${chapterverse}
		fi
		
	fi
	## third
	if [[ "$third" =~ [()] ]]; then
		trans="$(echo "$third" | sed 's/[()]//g' | tr '[:upper:]' '[:lower:]')"
	elif [[ "$third" =~ [1-9] ]]; then
		chapterverse=$third
		if [[ "${chapterverse}" == *":"* ]]; then
			chapter=$(echo "${chapterverse}" | awk -F':' '{ print $1 }')
			verse_all=$(echo "${chapterverse}" | awk -F':' '{ print $2 }')
			if [[ "$verse_all" == *"-"* ]]; then
				#verse=$verse_all
				verse_first=$(echo "${verse_all}" | awk -F'-' '{ print $1 }')
				verse_last=$(echo "${verse_all}" | awk -F'-' '{ print $2 }')
				verse_list=$(echo "${verse_last} - ${verse_first} + 1" | bc -l)
			else
				verse="$verse_all"
				verse_list=1
			fi
		elif [[ "${chapterverse}" == *"-"* ]]; then
			#verse=$verse_all
			verse_first=$(echo "${verse_all}" | awk -F'-' '{ print $1 }')
			verse_last=$(echo "${verse_all}" | awk -F'-' '{ print $2 }')
			verse_list=$(echo "${verse_last} - ${verse_first} + 1" | bc -l)
		else
			verse_list=1
			#verse_list=${chapterverse}
		fi
	fi
	## fourth
	if [[ "$fourth" =~ [()] ]]; then
		trans="$(echo "$fourth" | sed 's/[()]//g' | tr '[:upper:]' '[:lower:]')"
	fi
	if [ "$verse_list" -gt 1 ]; then
		echo -e "\n$book_upper $chapter:$verse_first-$verse_last"
		for verse in `seq $verse_first $verse_last`; do
			echo "$verse"
			verse_text=$(curl -s "https://biblehub.com/$trans/$book/$chapter-$verse.htm" | awk -F'title' '{ print $2 }' | sed -e 's/[></]//g' -e '/^$/ d' -e 's/&#8220;/"/g' -e 's/&#8221;/"/g' -e "s/&#8217;/'/g" -e 's/&#8212;/--/g' | awk -F"$(echo ${trans} | tr '[:lower:]' '[:upper:]')" '{ print $NF}' | cut -c 3-)
			#case ${#verse_text} in
			#	[0-3]) echo "Verse #$verse not found" ;;
			#	[4-9]|[0-9][0-9]|1[0-4][0-9]) echo "${verse_text}" | fmt -ns -w $(( $max_width / 2 + 8 )) -d '.!?,' | awk '{$1=toupper(substr($1,0,1))substr($1,2)}1' ;;
			#	1[5-9][0-9]|2[0-4][0-9]) echo "${verse_text}" | fmt -ns -w $(( $max_width / 4 * 3 + 2 )) -d '.!?,' | awk '{$1=toupper(substr($1,0,1))substr($1,2)}1' ;;
			#	2[5-9][0-9]|[3-9][0-9][0-9]) echo "${verse_text}" | fmt -ns -w ${max_width} -d '.!?,' | awk '{$1=toupper(substr($1,0,1))substr($1,2)}1' ;;
			#esac
			fmtVerses
		done
	else
		echo -e "\n$book_upper $chapter:$verse"
		verse_text=$(curl -s "https://biblehub.com/$trans/$book/$chapter-$verse.htm" | awk -F'title' '{ print $2 }' | sed -e 's/[></]//g' -e '/^$/ d' -e 's/&#8220;/"/g' -e 's/&#8221;/"/g' -e "s/&#8217;/'/g" -e 's/&#8212;/--/g' | awk -F"$(echo ${trans} | tr '[:lower:]' '[:upper:]')" '{ print $NF}' | cut -c 3-)
		#case "${#verse_text}" in
		#	[0-3]) echo "Verse #$verse not found" ;;
		#	[4-9]|[0-9][0-9]|1[0-4][0-9])
		#		echo ${verse_text} | fmt -ns -w $(( $max_width / 2 + 8 )) -d '.!?,' | awk '{$1=toupper(substr($1,0,1))substr($1,2)}1' ;;
		#	1[5-9][0-9]|2[0-9][0-9])
		#		echo ${verse_text} | fmt -ns -w $(( $max_width / 4 * 3 + 2 )) -d '.!?,' | awk '{$1=toupper(substr($1,0,1))substr($1,2)}1' ;;
		#	[3-9][0-9][0-9])
		#		echo "${verse_text}" | fmt -ns -w ${max_width} -d '.!?,' | awk '{$1=toupper(substr($1,0,1))substr($1,2)}1' ;;
		#esac
		fmtVerses
	fi
		
done
} #
#done < <(awk -v var=scripturelist '$0~var' RS= $path_to_verses | grep -v "^#\|Today") > "${path_to_verses}.tmp"


## script begins here either into a file or just std out
if [[ "$verse_file" == "TRUE" ]]; then
	trans=$(awk -v var=scripturelist '$0~var' RS= $path_to_verses | grep Today | awk -F'(' '{ print $2 }' | sed 's/[():]//g' | tr '[:upper:]' '[:lower:]')
	if [[ "$trans" == "" ]]; then trans=$default_trans; fi
	getVerses < <(awk -v var=scripturelist '$0~var' RS= $path_to_verses | grep -v "^#\|Today") > "${path_to_verses}.tmp"

	sed -i "" "/scripturewritten/ r$path_to_verses.tmp" $path_to_verses

	rm "${path_to_verses}.tmp"
else
	trans=$default_trans
	#max_width=$(( $(tput cols) / 6 * 5 ))
	max_width=$(( $(tput cols) / 2 ))
	#max_width=$(tput cols)
	getVerses <<< "$@"
	echo ""
fi

exit
