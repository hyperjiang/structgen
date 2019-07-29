package {{.Package}}

import (
	"github.com/huandu/go-sqlbuilder"
{{range $link := .Imports}}	"{{$link}}"
{{end}}
)

// {{.ModelName}} represents {{.TableName}} table
type {{.ModelName}} struct {
{{range $column := .Columns}}	{{$column.Name}} {{$column.Type}} `db:"{{$column.Orig}}" {{$column.Tags}}`
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
	return {{.ModelName}}Struct().UpdateForTag({{.InstanceName}}.TableName(), "update", {{.InstanceName}})
}

// DeleteBuilder returns a delete builder
func ({{.InstanceName}} *{{.ModelName}}) DeleteBuilder() *sqlbuilder.DeleteBuilder {
	return {{.ModelName}}Struct().DeleteFrom({{.InstanceName}}.TableName())
}

// GetByID gets a record by its id
func ({{.InstanceName}} *{{.ModelName}}) GetByID(db *sqlx.DB) error {
	sb := {{.InstanceName}}.SelectBuilder()
	q, args := sb.Where(sb.E("{{.PrimaryKey}}", {{.InstanceName}}.ID)).Build()
	return db.Get(&{{.InstanceName}}, q, args...)
}

// UpdateByID updates a record by its id
func ({{.InstanceName}} *{{.ModelName}}) UpdateByID(db *sqlx.DB) (sql.Result, error) {
	ub := {{.InstanceName}}.UpdateBuilder()
	q, args := ub.Where(ub.E("{{.PrimaryKey}}", {{.InstanceName}}.ID)).Build()
	return db.Exec(q, args...)
}

// DeleteByID delets a record by its id
func ({{.InstanceName}} *{{.ModelName}}) DeleteByID(db *sqlx.DB) (sql.Result, error) {
	rb := {{.InstanceName}}.DeleteBuilder()
	q, args := rb.Where(rb.E("{{.PrimaryKey}}", {{.InstanceName}}.ID)).Build()
	return db.Exec(q, args...)
}
