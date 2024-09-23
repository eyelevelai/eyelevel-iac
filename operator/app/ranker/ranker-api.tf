resource "helm_release" "ranker_api_service" {
  name       = "${var.ranker_internal.service}-api-cluster"
  namespace  = var.app.namespace

  chart      = "${local.module_path}/ranker/api/helm_chart"

  values = [
    yamlencode({
      dependencies = {
        cache = "${local.cache_settings.addr} ${local.cache_settings.port}"
      }
      image = var.ranker_internal.api.image
      nodeSelector = {
        node = var.ranker_internal.nodes.api
      }
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
      }
      service = {
        name      = "${var.ranker_internal.service}-api"
        namespace = var.app.namespace
        version   = var.ranker_internal.version
      }
    })
  ]
}