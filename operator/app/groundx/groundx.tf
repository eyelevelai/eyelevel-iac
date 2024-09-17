resource "helm_release" "groundx_service" {
  name       = "${var.groundx_internal.service}-cluster"
  namespace  = var.app.namespace
  chart      = "${local.module_path}/groundx/helm_chart"

  values = [
    yamlencode({
      dependencies = {
        cache    = "${var.cache_internal.service}.${var.app.namespace}.svc.cluster.local"
        database = "${var.db_internal.service}-cluster-pxc-haproxy.${var.app.namespace}.svc.cluster.local"
        file     = "${var.file_internal.service}-tenant-hl.${var.app.namespace}.svc.cluster.local"
        search   = "${var.search_internal.service}-cluster-master.${var.app.namespace}.svc.cluster.local"
        stream   = "${var.stream_internal.service}-cluster-cluster-kafka-bootstrap.${var.app.namespace}.svc.cluster.local"
      }
      image = var.groundx_internal.image
      nodeSelector = {
        node = var.groundx.node
      }
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
        runAsGroup = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1001) : 1001
        fsGroup    = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.GID, 1001) : 1001
      }
      service = {
        name      = var.groundx_internal.service
        namespace = var.app.namespace
      }
    })
  ]
}