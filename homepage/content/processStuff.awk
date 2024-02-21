{
	match($0, /^([ └├─│]*)(.+)$/, a)

	lines = gensub(/ /, " ", "g", a[1])

	match(a[2], /([^/]+)\/?$/, nameA)
	name = nameA[1]

	if(match(a[2], /\/$/)) {
		print lines name "<br>"
	} else {
		getline url < a[2]
		printf "%s<a href=\"%s\">%s</a><br>\n", lines, url, name
	}
}
