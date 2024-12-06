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
      nodeSelector = {
        node = var.cluster_internal.nodes.cpu_only
      }
      podSecurityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 65534) : 65534
        runAsGroup = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 65534) : 65534
        fsGroup    = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 65534) : 65534
      }
      redisAddress = "redis://${local.cache_settings.addr}:${local.cache_settings.port}"
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
    })
  ]
}