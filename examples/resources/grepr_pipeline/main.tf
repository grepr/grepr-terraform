terraform {
  required_providers {
    grepr = {
      source = "grepr-ai/grepr"
    }
  }
}

provider "grepr" {
  # Configure via environment variables:
  # GREPR_HOST, GREPR_CLIENT_ID, GREPR_CLIENT_SECRET
}

resource "grepr_pipeline" "example" {
  name = "example_pipeline"

  job_graph_json = jsonencode({
    vertices = [
      {
        type          = "datadog-log-agent-source"
        name          = "source"
        integrationId = var.integration_id
      },
      {
        type             = "grok-parser"
        name             = "parser"
        grokParsingRules = ["%{TIMESTAMP_ISO8601:timestamp} %{LOGLEVEL:level} %{GREEDYDATA:message}"]
      },
      {
        type      = "logs-iceberg-table-sink"
        name      = "sink"
        datasetId = var.dataset_id
      }
    ]
    edges = [
      "source -> parser",
      "parser -> sink"
    ]
  })

  desired_state = "RUNNING"

  tags = {
    environment = "example"
    managed_by  = "terraform"
  }

  wait_for_state = true
  state_timeout  = 300
}

variable "integration_id" {
  description = "The integration ID for the data source"
  type        = string
}

variable "dataset_id" {
  description = "The dataset ID for the sink"
  type        = string
}

output "pipeline_id" {
  description = "The ID of the created pipeline"
  value       = grepr_pipeline.example.id
}

output "pipeline_version" {
  description = "The current version of the pipeline"
  value       = grepr_pipeline.example.version
}

output "pipeline_state" {
  description = "The current state of the pipeline"
  value       = grepr_pipeline.example.state
}

output "pipeline_health" {
  description = "The health status of the pipeline"
  value       = grepr_pipeline.example.pipeline_health
}
