#!/bin/bash

CSS="css/sixfoisneuf.css"
DISQUS="-A static/utterances.html"
HEADER="--include-before-body=static/header.html"
HEADER_POST="--include-before-body=static/header-post.html"
FAVICON="--include-in-header=static/favicon.html"
GOATCOUNTER="--include-after-body=static/goatcounter.html --include-after-body=static/counterscale.html"
FOOTER="-A static/footer.html"
FOOTER_POST="-A static/footer-post.html"
#HIGHTLIGHT="--highlight-style=solarizeddark.theme"
METADATA="--metadata-file=pandoc/.metadata.yml"
PANDOCOPTS="--mathjax --lua-filter=pandoc/dotgraph.lua --lua-filter=pandoc/remove-h1.lua --shift-heading-level-by=-0 --standalone --table-of-contents --template=static/custom-template.html"

PANDOC="pandoc --from markdown -c $CSS $FAVICON $HEADER $HIGHTLIGHT $METADATA $GOATCOUNTER $PANDOCOPTS"
PANDOC_POST="pandoc --from markdown -c $CSS $FAVICON $HEADER_POST $HIGHTLIGHT $METADATA $GOATCOUNTER $PANDOCOPTS"
MARKDOWNOPTS="$PANDOC $FOOTER"
MARKDOWNOPTS_POST="$PANDOC_POST $FOOTER_POST"
MARKDOWNOPTS_DISQUS="${PANDOC_POST} $DISQUS $FOOTER_POST"

DEPLOY_DIRECTORY="deploy"
SITE_NAME="Yang"

function generate_RSS_feed {
    echo "Generating RSS feed"
    declare items
    while read -r file; do
        url_path=$(echo "$file" | sed "s:docs\/::g" | sed "s:\.md::g")
        date=$(grep "date:" "$file" | sed "s/date: //g"| awk '{printf $1}')
        title=$(grep "title:" "$file" | sed "s/title: //g")
        html=$(pandoc "$file")
        items+=$(cat << END
    <item>
      <title>${title}</title>
      <description><![CDATA[${html}]]></description>
      <link>https://www.imtxc.com/$url_path</link>
      <pubDate>${date}</pubDate>
    </item>
END
)
    done < <(find "post_source" "post_issues" -name '*.md' ! -name "index.md")

    pub_date=$(date -R)
    template=$(cat << END
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0">
  <channel>
    <title>${SITE_NAME}</title>
    <link>https://www.imtxc.com/</link>
    <description>yang's</description>
    <language>zh-cn</language>
    <pubDate>${pub_date}</pubDate>
    ${items}
  </channel>
</rss>
END
)
    touch ${DEPLOY_DIRECTORY}/rss.xml
    echo  "$template" > ${DEPLOY_DIRECTORY}/rss.xml
}

clean ()
{
	echo "Cleaning ..."
	rm -rf index.md $DEPLOY_DIRECTORY
	echo "Done."
}

deploy ()
{
	echo "Deploying ..."
	echo "rsync -e "ssh -p SSH_PORT" -P -rvzc --delete $DEPLOY_DIRECTORY/ SSH_USER)@SSH_HOST:SSH_TARGET_DIR --cvs-exclude"
	echo "Done."
}

usage ()
{
	echo "./gen.sh -b : build blog"
	echo "./gen.sh -c : clean deploy dir"
	echo "./gen.sh -d : deploy"
	echo "./gen.sh -h : this message"
}

list_to_md() {
  input_file=$1
  output_file=$2
  temp_file=$(mktemp)

  sort -r -k1,1 "$input_file" > "$temp_file"

  prev_year=""
  echo "" > "$output_file"

  months=(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)

  while read -r line; do
    date=$(echo "$line" | awk '{print $1}')
    content=$(echo "$line" | sed 's/^[0-9]\{6\} //')

    year="20${date:0:2}"
    month_index=$((10#${date:2:2} - 1))
    day=${date:4:2}

    month=${months[$month_index]}

    if [[ "$year" != "$prev_year" ]]; then
      if [[ -n "$prev_year" ]]; then
        echo "</ul>" >> "$output_file"
      fi
      echo "<h2 class=\"year\">$year</h2>" >> "$output_file"
      echo "<ul class=\"posts\">" >> "$output_file"
      prev_year="$year"
    fi

    formatted_line=$(echo "$content" | sed "s|</a>|</a><span class=\"date\"> on $month $day</span><blockquote></blockquote>|")

    echo "  $formatted_line" >> "$output_file"
  done < "$temp_file"

  if [[ -n "$prev_year" ]]; then
    echo "</ul>" >> "$output_file"
  fi
  rm "$temp_file"
}

build ()
{
	mkdir -p $DEPLOY_DIRECTORY/
	mkdir -p $DEPLOY_DIRECTORY/diagrams
	rm -f index.md index.txt
	touch index.md index.txt

	for file in ./post_source/*.md ./post_issues/*.md
	do
		[ -e "$file" ] || continue
		TITLE=""
		POSTDATE=""
		DATE=""
		COMMENT=""
		slug=""
		POST=$(basename "$file" .md)
		post_html=""
		t_count=0
		while IFS= read -r line
		do
			if [[ "$line" =~ (^---$) ]]
			then
				t_count=$((t_count+1))
			fi
			if [[ t_count -ge 2 ]]; then
				break
			fi

			if [[ "$line" =~ itle:(.*$) ]]
			then
				TITLE=$(echo "$line" |sed -n 's/.itle: //p'| sed 's/^"\(.*\)"$/\1/')
			fi

			if [[ "$line" =~ ate:(.*$) ]]
			then
				POSTDATE=$(echo "$line" |sed -n 's/.ate: //p')
			fi

			if [[ "$line" =~ odify:(.*$) ]]
			then
				POSTDATE=$(echo "$line" |sed -n 's/.odify: //p')
			fi

			if [[ "$line" =~ lug:(.*$) ]]
			then
				slug=$(echo "$line" |sed -n 's/.lug: //p')
			fi

			if [[ "$line" =~ omment:(.*$) ]]
			then
				COMMENT=$(echo "$line" |sed -n 's/.omment: //p')
			fi
		done < "$file"

		SORTDATE=$(date -d "$POSTDATE" +%y%m%d)

		if [[ c$COMMENT == "cno" ]]; then
			MKCMD=$MARKDOWNOPTS_POST
		else
			MKCMD=$MARKDOWNOPTS_DISQUS
		fi

		if [[ ! -z $slug ]]; then
			post_html=$slug.html
		else
			post_html=$POST.html
		fi

		echo "$MKCMD $file -o $DEPLOY_DIRECTORY/$post_html"
		$MKCMD "$file" -o $DEPLOY_DIRECTORY/$post_html

		DATE=$(echo -n $POSTDATE |cut -d ' ' -f 1)

		echo "$SORTDATE" '<li> <a href="'"$post_html"'">'"$TITLE"'</a></li>' >> index.txt
	done

  list_to_md index.txt index.md

	echo "$MARKDOWNOPTS index.md -o $DEPLOY_DIRECTORY/index.html"

	$MARKDOWNOPTS index.md --metadata=pagetitle:"${SITE_NAME}" -o $DEPLOY_DIRECTORY/index.html
	$MARKDOWNOPTS_POST about.md --metadata=pagetitle:"About" -o $DEPLOY_DIRECTORY/about.html

	echo "copying css file"
	cp -r css "$DEPLOY_DIRECTORY"/

	cp -rp post_source/images "$DEPLOY_DIRECTORY"/

	echo "images"
	cp static/favicon.png "$DEPLOY_DIRECTORY"/
	cp static/background.png "$DEPLOY_DIRECTORY"/

	rm -rf ${DEPLOY_DIRECTORY}/pics
  mkdir -p ${DEPLOY_DIRECTORY}/pics

	echo Done.
}

while getopts ":bcdh:" opt; do
	case $opt in
		c)
			clean
			exit 0;
			;;
		b)
			build
      generate_RSS_feed
			exit 0;
			;;
		d)
			deploy
			exit 0;
			;;
		h)
			usage
			exit 0;
			;;
		\?)
			usage
			exit 1;
			;;
		:)
			usage
			exit 1;
			;;
	esac
done

exit 0

