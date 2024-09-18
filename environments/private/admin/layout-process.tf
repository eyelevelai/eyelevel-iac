resource "helm_release" "layout_process_service" {
  count = local.create_layout ? 1 : 0

  depends_on = [kubernetes_namespace.eyelevel, kubernetes_config_map.layout_config_file]

  name       = "${var.layout_internal.service}-process"
  namespace  = var.app.namespace

  chart      = "${path.module}/../../../modules/layout/process/helm_chart"

  values = [
    yamlencode({
      dependencies = {
        cache = "${var.cache_internal.service}.${var.app.namespace}.svc.cluster.local"
        file  = "${var.file_internal.service}-tenant-hl.${var.app.namespace}.svc.cluster.local"
      }
      image = var.layout_internal.process.image
      queues = (
        var.layout_ocr.type == "google" ?
          "process_queue,ocr_queue,map_queue,save_queue" :
          "process_queue,map_queue,save_queue"
      )
      securityContext = {
        runAsUser  = local.is_openshift ? coalesce(data.external.get_uid_gid[0].result.UID, 1001) : 1001
      }
      service = {
        name      = "${var.layout_internal.service}-process"
        namespace = var.app.namespace
        version   = var.layout_internal.version
      }
    })
  ]

  timeout = 1800
}