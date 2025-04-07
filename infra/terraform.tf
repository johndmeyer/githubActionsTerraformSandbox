terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.11.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_ecrpublic_repository" "tf-sandbox" {
  repository_name = "tf-sandbox"
}

resource "aws_ecs_cluster" "tf-sandbox" {
  name = "tf-sandbox"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "tf-sandbox" {
  family = "tf-sandbox"
  requires_compatibilities = ["FARGATE"]
  container_definitions = jsonencode([
    {
      name      = "tf-sandbox-api"
      image     = "service-first"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])

  volume {
    name      = "service-storage"
    host_path = "/ecs/service-storage"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  }
}