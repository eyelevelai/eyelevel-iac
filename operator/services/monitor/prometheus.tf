locals {
  monitor = {
    port  = 80
    url   = "http://${var.monitor_internal.service}-prometheus-server.${var.app_internal.namespace}.svc.cluster.local"
  }
}

resource "helm_release" "prometheus" {
  count = local.create_monitor ? 1 : 0

  name       = var.monitor_internal.service
  namespace  = var.app_internal.namespace

  chart      = var.monitor_internal.chart.name
  repository = var.monitor_internal.chart.url

  values = [
    yamlencode({
      alertmanager = {
        nodeSelector = {
          node = var.cluster_internal.nodes.cpu_only
        }
        podSecurityContext = {
          runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 65534) : 65534
          runAsGroup = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 65534) : 65534
          fsGroup    = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 65534) : 65534
        }
        securityContext = {
          runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 65534) : 65534
          runAsGroup = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 65534) : 65534
          fsGroup    = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 65534) : 65534
        }
        tolerations = [{
          effect = "NoSchedule"
          key    = "node"
          value  = var.cluster_internal.nodes.cpu_only
        }]
      }
      extraScrapeConfigs = <<-EOT
        - job_name: 'redis-exporter'
          static_configs:
            - targets:
                - ${var.monitor_internal.service}-redis-prometheus-redis-exporter.${var.app_internal.namespace}.svc.cluster.local:9121
      EOT
      kube-state-metrics = {
        nodeSelector = {
          node = var.cluster_internal.nodes.cpu_only
        }
        securityContext = {
          runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 65534) : 65534
          runAsGroup = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 65534) : 65534
          fsGroup    = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 65534) : 65534
        }
        tolerations = [{
          effect = "NoSchedule"
          key    = "node"
          value  = var.cluster_internal.nodes.cpu_only
        }]
      }
      prometheus-node-exporter = {
        nodeSelector = {
          node = var.cluster_internal.nodes.cpu_only
        }
        securityContext = {
          runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 65534) : 65534
          runAsGroup = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 65534) : 65534
          fsGroup    = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 65534) : 65534
        }
        tolerations = [{
          effect = "NoSchedule"
          key    = "node"
          value  = var.cluster_internal.nodes.cpu_only
        }]
      }
      prometheus-pushgateway = {
        nodeSelector = {
          node = var.cluster_internal.nodes.cpu_only
        }
        securityContext = {
          runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 65534) : 65534
          runAsGroup = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 65534) : 65534
          fsGroup    = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 65534) : 65534
        }
        tolerations = [{
          effect = "NoSchedule"
          key    = "node"
          value  = var.cluster_internal.nodes.cpu_only
        }]
      }
      server = {
        nodeSelector = {
          node = var.cluster_internal.nodes.cpu_only
        }
        securityContext = {
          runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 65534) : 65534
          runAsGroup = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 65534) : 65534
          fsGroup    = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 65534) : 65534
        }
        tolerations = [{
          effect = "NoSchedule"
          key    = "node"
          value  = var.cluster_internal.nodes.cpu_only
        }]
      }
      serverFiles = {
        "alerting_rules.yml" = {
          groups = [
            {
              name = "${var.layout_internal.service}-zero-capacity-alerts"
              rules = [
                {
                  alert = "${var.layout_internal.service}RequestsZero"
                  expr = "sum(redis_key_value{key=~\"${var.layout_internal.service}:.*:requests\"}) == 0"
                  for = "3m"
                  labels = {
                    severity = "critical"
                  }
                  annotations = {
                    layout = "${var.layout_internal.service} capacity requests are consistently zero"
                    description = "The metric '${var.layout_internal.service}_capacity_requests' has been zero for the past 3 minutes. Trigger scaling."
                  }
                }
              ]
            },
            {
              name = "${var.ranker_internal.service}-zero-capacity-alerts"
              rules = [
                {
                  alert = "${var.ranker_internal.service}RequestsZero"
                  expr = "sum(redis_key_value{key=~\"${var.ranker_internal.service}:.*:requests\"}) == 0"
                  for = "3m"
                  labels = {
                    severity = "critical"
                  }
                  annotations = {
                    ranker = "${var.ranker_internal.service} capacity requests are consistently zero"
                    description = "The metric '${var.ranker_internal.service}_capacity_requests' has been zero for the past 3 minutes. Trigger scaling."
                  }
                }
              ]
            },
            {
              name = "${var.summary_internal.service}-zero-capacity-alerts"
              rules = [
                {
                  alert = "${var.summary_internal.service}RequestsZero"
                  expr = "sum(redis_key_value{key=~\"${var.summary_internal.service}:.*:requests\"}) == 0"
                  for = "3m"
                  labels = {
                    severity = "critical"
                  }
                  annotations = {
                    summary = "${var.summary_internal.service} capacity requests are consistently zero"
                    description = "The metric '${var.summary_internal.service}_capacity_requests' has been zero for the past 3 minutes. Trigger scaling."
                  }
                }
              ]
            },
          ]
        }
      }
    })
  ]
}

resource "helm_release" "prometheus_redis_exporter" {
  count = local.create_monitor ? 1 : 0

  depends_on = [helm_release.prometheus]

  name       = "${var.monitor_internal.service}-redis"
  namespace  = var.app_internal.namespace

  chart      = var.monitor_internal.redis.name
  repository = var.monitor_internal.redis.url

  values = [
    yamlencode({
      extraArgs = {
        check-keys = "${var.layout_internal.service}:*:requests,${var.ranker_internal.service}:*:requests,${var.summary_internal.service}:*:requests"
      }
      nodeSelector = {
        node = var.cluster_internal.nodes.cpu_only
      }
      podSecurityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 10001) : 10001
        runAsGroup = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 10001) : 10001
      }
      redisAddress = "redis://${local.cache_settings.addr}:${local.cache_settings.port}"
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 10001) : 10001
        runAsGroup = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 10001) : 10001
        fsGroup    = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 10001) : 10001
      }
      tolerations = [{
        effect = "NoSchedule"
        key    = "node"
        value  = var.cluster_internal.nodes.cpu_only
      }]
    })
  ]
}

resource "helm_release" "prometheus_adapter" {
  count = local.create_monitor ? 1 : 0

  depends_on = [helm_release.prometheus]

  name       = "${var.monitor_internal.service}-adapter"
  namespace  = var.app_internal.namespace

  chart      = var.monitor_internal.adapter.name
  repository = var.monitor_internal.adapter.url

  values = [
    yamlencode({
      nodeSelector = {
        node = var.cluster_internal.nodes.cpu_only
      }
      podSecurityContext = {
        fsGroup    = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 10001) : 10001
      }
      prometheus = {
        port       = local.monitor.port
        url        = local.monitor.url
      }
      rules = {
        custom = [
          {
            seriesQuery = "redis_key_value{key=~\"${var.layout_internal.service}:.*:requests\"}"
            resources = {
              template = "<<.Resource>>"
            }
            name = {
              matches = ".*"
              as = "${var.layout_internal.service}_capacity_requests"
            }
            metricsQuery = "sum(redis_key_value{key=~\"${var.layout_internal.service}:.*:requests\"})"
          },
          {
            seriesQuery = "redis_key_value{key=~\"${var.ranker_internal.service}:.*:requests\"}"
            resources = {
              template = "<<.Resource>>"
            }
            name = {
              matches = ".*"
              as = "${var.ranker_internal.service}_capacity_requests"
            }
            metricsQuery = "sum(redis_key_value{key=~\"${var.ranker_internal.service}:.*:requests\"})"
          },
          {
            seriesQuery = "redis_key_value{key=~\"${var.summary_internal.service}:.*:requests\"}"
            resources = {
              template = "<<.Resource>>"
            }
            name = {
              matches = ".*"
              as = "${var.summary_internal.service}_capacity_requests"
            }
            metricsQuery = "sum(redis_key_value{key=~\"${var.summary_internal.service}:.*:requests\"})"
          }
        ]
      }
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 10001) : 10001
      }
      tolerations = [{
        effect = "NoSchedule"
        key    = "node"
        value  = var.cluster_internal.nodes.cpu_only
      }]
    })
  ]
}