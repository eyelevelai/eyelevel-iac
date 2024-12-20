resource "helm_release" "queue_service" {
  name       = "${var.queue_internal.service}-cluster"
  namespace  = var.app_internal.namespace
  chart      = "${local.module_path}/queue/helm_chart"

  values = [
    yamlencode({
      dependencies = {
        groundx  = "${var.groundx_internal.service}.${var.app_internal.namespace}.svc.cluster.local"
      }
      image = var.queue_internal.image
      nodeSelector = {
        node = var.cluster_internal.nodes.cpu_only
      }
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
        runAsGroup = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1001) : 1001
        fsGroup    = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1001) : 1001
      }
      service = {
        name      = var.queue_internal.service
        namespace = var.app_internal.namespace
        version   = var.queue_internal.version
      }
    })
  ]
}