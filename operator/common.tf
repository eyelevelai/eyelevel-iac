locals {
  ingest_only  = var.cluster.search == false
  is_openshift = var.cluster.type == "openshift"

  create_cache = var.cache_existing.addr == null || var.cache_existing.is_instance == null || var.cache_existing.port == null
  cache_settings = {
    addr        = coalesce(var.cache_existing.addr, "${var.cache_internal.service}.${var.app_internal.namespace}.svc.cluster.local")
    is_instance = coalesce(var.cache_existing.is_instance, var.cache_internal.is_instance)
    port        = coalesce(var.cache_existing.port, var.cache_internal.port)
  }

  create_database = var.db_existing.port == null || var.db_existing.ro == null || var.db_existing.rw == null
  db_endpoints = {
    port = coalesce(var.db_existing.port, var.db_internal.port)
    ro   = coalesce(var.db_existing.ro, "${var.db_internal.service}-cluster-pxc-db-haproxy.${var.app_internal.namespace}.svc.cluster.local")
    rw   = coalesce(var.db_existing.rw, "${var.db_internal.service}-cluster-pxc-db-haproxy.${var.app_internal.namespace}.svc.cluster.local")
  }

  create_file = var.file_existing.base_domain == null || var.file_existing.bucket == null || var.file_existing.password == null || var.file_existing.port == null || var.file_existing.ssl == null
  file_settings = {
    base_domain = coalesce(var.file_existing.base_domain, "${var.file_internal.service}.${var.app_internal.namespace}.svc.cluster.local")
    bucket      = coalesce(var.file_existing.bucket, var.file.upload_bucket)
    dependency  = coalesce(var.file_existing.base_domain, "${var.file_internal.service}-tenant-hl.${var.app_internal.namespace}.svc.cluster.local")
    password    = coalesce(var.file_existing.password, var.file.password)
    port        = coalesce(var.file_existing.port, var.file_internal.port)
    ssl         = coalesce(var.file_existing.ssl, var.file_resources.ssl)
    username    = coalesce(var.file_existing.username, var.file.username)
  }

  create_graph = var.cluster.search && var.app.graph && (var.graph_existing.addr == null)
  graph_settings = {
    addr        = coalesce(var.graph_existing.addr, "${var.graph_internal.service}.${var.app_internal.namespace}.svc.cluster.local")
  }

  create_monitor = var.app.monitor

  create_search = var.cluster.search && (var.search_existing.base_domain == null || var.search_existing.base_url == null || var.search_existing.port == null)
  search_settings = {
    base_domain = coalesce(var.search_existing.base_domain, "${var.search_internal.service}-cluster-master.${var.app_internal.namespace}.svc.cluster.local")
    base_url    = coalesce(var.search_existing.base_url, "https://${var.search_internal.service}-cluster-master.${var.app_internal.namespace}.svc.cluster.local:${var.search_internal.port}")
    port        = coalesce(var.search_existing.port, var.search_internal.port)
  }

  create_stream = var.stream_existing.base_domain == null || var.stream_existing.base_url == null || var.stream_existing.port == null
  stream_settings = {
    base_domain = coalesce(var.stream_existing.base_domain, "${var.stream_internal.service}-cluster-cluster-kafka-bootstrap.${var.app_internal.namespace}.svc.cluster.local")
    port        = coalesce(var.stream_existing.port, var.stream_internal.port)
  }

  create_summary = var.summary_existing.api_key == null || var.summary_existing.base_url == null

  summary_credentials = {
    api_key  = coalesce(var.summary_existing.api_key, var.admin.api_key)
    base_url = coalesce(var.summary_existing.base_url, "http://${var.summary_internal.service}-api.${var.app_internal.namespace}.svc.cluster.local")
  }
}