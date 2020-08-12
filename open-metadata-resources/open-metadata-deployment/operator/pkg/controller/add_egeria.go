package controller

import (
	"github.com/planetf1/egeria-operator/pkg/controller/egeria"
)

func init() {
	// AddToManagerFuncs is a list of functions to create controllers and add them to a manager.
	AddToManagerFuncs = append(AddToManagerFuncs, egeria.Add)
}
