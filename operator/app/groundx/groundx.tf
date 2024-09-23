resource "helm_release" "groundx_service" {
  name       = "${var.groundx_internal.service}-cluster"
  namespace  = var.app.namespace
  chart      = "${local.module_path}/groundx/helm_chart"

  values = [
    yamlencode({
      dependencies = {
        cache    = "${local.cache_settings.addr} ${local.cache_settings.port}"
        database = "${local.db_endpoints.ro} ${local.db_endpoints.port}"
        file     = "${local.file_settings.dependency} ${local.file_settings.port}"
        search   = "${local.search_settings.base_domain} ${local.search_settings.port}"
        stream   = "${local.stream_settings.base_domain} ${local.stream_settings.port}"
      }
      image = var.groundx_internal.image
      nodeSelector = {
        node = var.groundx_internal.node
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