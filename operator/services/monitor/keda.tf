resource "helm_release" "keda" {
  count = local.create_monitor ? 1 : 0

  depends_on = [helm_release.prometheus]

  name       = "${var.monitor_internal.service}-keda"
  namespace  = var.app_internal.namespace

  chart      = var.monitor_internal.keda.name
  repository = var.monitor_internal.keda.url

  values = [
    yamlencode({
      nodeSelector = {
        node = var.cluster_internal.nodes.cpu_memory
      }
      podSecurityContext = {
        metricServer = {
          runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1000) : 1000
          runAsGroup = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1000) : 1000
          fsGroup    = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1000) : 1000
        }
        operator = {
          runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1000) : 1000
          runAsGroup = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1000) : 1000
          fsGroup    = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1000) : 1000
        }
        webhooks = {
          runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1000) : 1000
          runAsGroup = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1000) : 1000
          fsGroup    = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1000) : 1000
        }
      }
      tolerations = [{
        effect = "NoSchedule"
        key    = "node"
        value  = var.cluster_internal.nodes.cpu_memory
      }]
    })
  ]
}

resource "helm_release" "keda_mods" {
  count = local.create_monitor ? 1 : 0

  depends_on = [helm_release.keda]

  name      = "${var.monitor_internal.service}-keda-mods"
  namespace = var.app_internal.namespace

  chart     = "${local.module_path}/monitor/helm_chart"

  values = [
    yamlencode({
      nodeSelector = {
        node = var.cluster_internal.nodes.cpu_memory
      }
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1000) : 1000
        runAsGroup = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1000) : 1000
        fsGroup    = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1000) : 1000
      }
      service = {
        name          = "${var.monitor_internal.service}-keda-mods"
        namespace     = var.app_internal.namespace
      }
      settings = {
        serverAddress = "${local.monitor.url}:${local.monitor.port}"
        query         = "ALERTS{alertname=\"summaryRequestsZero\",alertstate=\"firing\"}"
        target        = "summary-inference"
        threshold     = "1"
      }
    })
  ]
}