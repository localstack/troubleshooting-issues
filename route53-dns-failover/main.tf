# Note: This file is based on https://github.com/mineiros-io/terraform-aws-route53/blob/master/examples/failover-routing/main.tf

# ---------------------------------------------------------------------------------------------------------------------
# ROUTE53 ZONE WITH RECORDS THAT HAVE A FAILOVER ROUTING POLICY ATTACHED
#
# Failover routing lets you route traffic to a resource when the resource is healthy or to a different resource when the
# first resource is unhealthy. The primary and secondary records can route traffic to anything from an Amazon S3 bucket
# that is configured as a website to a complex tree of records.
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# We configure two records with associated healthchecks. Route53 will route the traffic to the secondary record if
# the healthcheck of the primary record reports an unhealthy status.
#
# For more information on DNS failover with Route53, please check the related documentation:
# https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy.html#routing-policy-failover
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_route53_health_check" "primary" {
  fqdn              = "host.docker.internal"
  port              = 8000
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = 5
  request_interval  = 30
}

resource "aws_route53_zone" "zone" {
  name                         = "example.com"
}

module "route53" {
  source  = "mineiros-io/route53/aws"
  version = "~> 0.6.0"

  skip_delegation_set_creation = true
  zone_id                = aws_route53_zone.zone.id

  records = [
    {
      type           = "CNAME"
      name           = "example.com"
      set_identifier = "primary"
      failover       = "PRIMARY"
      health_check_id = aws_route53_health_check.primary.id
      alias = {
        name                   = "target1.example.com"
        zone_id                = aws_route53_zone.zone.id
        evaluate_target_health = true
      }
    },
    {
      type            = "CNAME"
      set_identifier  = "secondary"
      failover        = "SECONDARY"
      alias = {
        name                   = "target2.example.com"
        zone_id                = aws_route53_zone.zone.id
        evaluate_target_health = true
      }
    },
    {
      type = "CNAME"
      name = "target1.example.com"
      records = ["target1.execute-api.localhost.localstack.cloud"]
    },
    {
      type = "CNAME"
      name = "target2.example.com"
      records = ["target2.execute-api.localhost.localstack.cloud"]
    }
  ]
}
