package main

import (
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"os"
	"path"
	"text/template"

	"github.com/hyperjiang/php"
	"github.com/spf13/viper"
	"github.com/volatiletech/sqlboiler/drivers"
	"github.com/volatiletech/sqlboiler/drivers/sqlboiler-mysql/driver"
	"github.com/volatiletech/sqlboiler/strmangle"
)

type column struct {
	Name string
	Orig string
	Type string
	Tags string
}

type tplData struct {
	Package      string
	Imports      []string
	ModelName    string
	InstanceName string
	StructName   string
	TableName    string
	PrimaryKey   string
	Columns      []column
}

func main() {
	var configFile, templateFile string

	flag.StringVar(&configFile, "c", "config.toml", "Filename of config file")
	flag.StringVar(&templateFile, "t", "struct.tpl", "Filename of template file")
	flag.Parse()

	viper.SetConfigFile(configFile)
	if err := viper.ReadInConfig(); err != nil {
		fatalf("Can't read config: %v", err)
	}

	b, err := ioutil.ReadFile(templateFile)
	if err != nil {
		fatalf("failed to load template: %s", templateFile)
	}

	tpl := template.Must(template.New("struct").Parse(string(b)))

	var output io.Writer
	if viper.GetString("go.output") == "stdout" {
		output = os.Stdout
	}

	config := drivers.Config{
		"whitelist": viper.GetStringSlice("mysql.whitelist"),
		"blacklist": viper.GetStringSlice("mysql.blacklist"),
		"user":      viper.GetString("mysql.user"),
		"pass":      viper.GetString("mysql.pass"),
		"host":      viper.GetString("mysql.host"),
		"port":      viper.GetInt("mysql.port"),
		"dbname":    viper.GetString("mysql.dbname"),
		"sslmode":   viper.GetString("mysql.sslmode"),
	}

	dbinfo, err := driver.Assemble(config)
	if err != nil {
		log.Fatal(err)
	}

	for _, table := range dbinfo.Tables {
		modelName := strmangle.TitleCase(strmangle.Singular(table.Name))
		instanceName := php.Lcfirst(modelName)
		if output == nil {
			file := path.Join(viper.GetString("go.output"), modelName+".go")
			f, err := os.Create(file)
			if err != nil {
				fatalf("Fail to open output file: %v", err)
			}
			defer f.Close()

			output = f
		}

		var pkey = ""
		if len(table.PKey.Columns) == 1 {
			pkey = table.PKey.Columns[0]
		}

		var cols []column
		for _, c := range table.Columns {
			// replace auto increment primary as ID, and remove update tag from it
			var name string
			var updateTag = "fieldtag:\"update\""
			if pkey != "" && c.Default == "auto_increment" {
				name = "ID"
				updateTag = ""
			} else {
				name = strmangle.TitleCase(c.Name)
			}
			cols = append(cols, column{
				Name: name,
				Orig: c.Name,
				Type: convertType(c.Type),
				Tags: updateTag,
			})
		}
		data := tplData{
			Package:      viper.GetString("go.package"),
			Imports:      viper.GetStringSlice("go.imports"),
			ModelName:    modelName,
			InstanceName: instanceName,
			StructName:   instanceName + "Struct",
			TableName:    table.Name,
			PrimaryKey:   pkey,
			Columns:      cols,
		}
		if err := tpl.Execute(output, data); err != nil {
			log.Fatal(err)
		}
	}
}

func fatalf(format string, v ...interface{}) {
	log.Fatal(fmt.Sprintf(format, v...))
}

func convertType(t string) string {
	r := viper.GetString("type." + t)
	if r == "" {
		r = t
	}
	return r
}
