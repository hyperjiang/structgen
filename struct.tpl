package {{.Package}}

import (
	"time"

	"github.com/huandu/go-sqlbuilder"
)

// {{.ModelName}} represents {{.TableName}} table
type {{.ModelName}} struct {
{{range $column := .Columns}}	{{$column.Name}} {{$column.Type}} `db:"{{$column.Orig}}"`
{{end}}}

var {{.StructName}} *sqlbuilder.Struct

func init() {
	{{.StructName}} = sqlbuilder.NewStruct(new({{.ModelName}}))
}

// {{.ModelName}}Struct returns the sql builder struct for the table
func {{.ModelName}}Struct() *sqlbuilder.Struct {
	return {{.StructName}}
}

// TableName returns the table name
func ({{.InstanceName}} *{{.ModelName}}) TableName() string {
	return "{{.TableName}}"
}

// SelectBuilder returns a select builder
func ({{.InstanceName}} *{{.ModelName}}) SelectBuilder() *sqlbuilder.SelectBuilder {
	return {{.ModelName}}Struct().SelectFrom({{.InstanceName}}.TableName())
}

// InsertBuilder returns an insert builder
func ({{.InstanceName}} *{{.ModelName}}) InsertBuilder() *sqlbuilder.InsertBuilder {
	return {{.ModelName}}Struct().InsertInto({{.InstanceName}}.TableName(), {{.InstanceName}})
}

// UpdateBuilder returns an update builder
func ({{.InstanceName}} *{{.ModelName}}) UpdateBuilder() *sqlbuilder.UpdateBuilder {
	return {{.ModelName}}Struct().Update({{.InstanceName}}.TableName(), {{.InstanceName}})
}

// DeleteBuilder returns a delete builder
func ({{.InstanceName}} *{{.ModelName}}) DeleteBuilder() *sqlbuilder.DeleteBuilder {
	return {{.ModelName}}Struct().DeleteFrom({{.InstanceName}}.TableName())
}
