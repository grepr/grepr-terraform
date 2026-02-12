// Package main is the entry point for the Grepr Terraform provider.
//
// This provider allows users to manage Grepr pipelines (async streaming jobs) through
// Terraform configuration. It communicates with the Grepr API using OAuth2 authentication
// via Auth0.
//
// Usage:
//
//	provider "grepr" {
//	  host          = "https://myorg.app.grepr.ai/api"
//	  client_id     = var.grepr_client_id
//	  client_secret = var.grepr_client_secret
//	}
//
//	resource "grepr_pipeline" "example" {
//	  name           = "my_pipeline"
//	  job_graph_json = jsonencode({...})
//	}
//
// For more information, see the provider documentation.
package main

import (
	"context"
	"flag"
	"log"

	"github.com/grepr-ai/terraform-provider-grepr/internal/provider"
	"github.com/hashicorp/terraform-plugin-framework/providerserver"
)

// version is set at build time via -ldflags "-X main.version=X.Y.Z"
var (
	version string = "dev"
)

func main() {
	var debug bool

	// The debug flag enables running the provider in debug mode, which allows
	// attaching a debugger like Delve. This is useful for development.
	flag.BoolVar(&debug, "debug", false, "set to true to run the provider with support for debuggers like delve")
	flag.Parse()

	opts := providerserver.ServeOpts{
		// Address is the full registry address for this provider.
		// Users reference this as "grepr-ai/grepr" in their Terraform configuration.
		Address: "registry.terraform.io/grepr-ai/grepr",
		Debug:   debug,
	}

	err := providerserver.Serve(context.Background(), provider.New(version), opts)
	if err != nil {
		log.Fatal(err.Error())
	}
}
