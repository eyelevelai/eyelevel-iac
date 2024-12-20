resource "helm_release" "redis" {
  count = local.create_cache ? 1 : 0

  name      = var.cache_internal.service
  namespace = var.app_internal.namespace

  chart     = "${local.module_path}/redis/helm_chart"

  values = [
    yamlencode({
      image = var.cache_internal.image
      nodeSelector = {
        node = var.cluster_internal.nodes.cpu_memory
      }
      persistence = {
        mountPath = var.cache_internal.mount_path
      }
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
        runAsGroup = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1001) : 1001
        fsGroup    = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1001) : 1001
      }
      service = {
        name         = var.cache_internal.service
        namespace    = var.app_internal.namespace
        port         = var.cache_internal.port
        replicaCount = var.cache_resources.replicas
      }
    })
  ]
}