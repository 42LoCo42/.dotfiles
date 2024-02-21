package main

import (
	"bytes"
	"log"
	"os"
	"strings"
	"text/template"
)

type File struct {
	Title string
	Path  string
	Body  *bytes.Buffer
}

func main() {
	if err := os.Chdir("html"); err != nil {
		log.Fatal("could not enter HTML dir: ", err)
	}

	final := template.Must(template.ParseFiles("final.tmpl"))

	base := template.Must(template.New("").Funcs(template.FuncMap{
		"arr": func(values ...any) []any {
			return values
		},
	}).ParseFiles(
		"prompt.tmpl",
		"../tree.html",
	))

	files := []*File{{
		Title: "Hi! 🏳️‍⚧️ 🏳️‍🌈 💜",
		Path:  "index.html.in",
	}, {
		Title: "My matrix instance",
		Path:  "matrix.html.in",
	}}

	// read & build all files
	for _, file := range files {
		outName := strings.TrimSuffix(file.Path, ".in")
		outPath := "../out/" + outName
		outFile, err := os.Create(outPath)
		if err != nil {
			log.Fatal("could not open output file: ", err)
		}
		defer outFile.Close()

		file.Body = bytes.NewBuffer(nil)

		tmpl := template.Must(base.ParseFiles(file.Path))
		if err := tmpl.ExecuteTemplate(file.Body, file.Path, nil); err != nil {
			log.Fatal("could not execute template: ", err)
		}

		if err := final.Execute(outFile, file); err != nil {
			log.Fatal("could not execute final template: ", err)
		}

		log.Print("Wrote ", outName)
	}
}
