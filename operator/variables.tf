# OPERATOR

variable "admin" {
  description = "Administrator account information for EyeLevel"
  type        = object({
    # should be a UUID, generate using uuid.sh
    api_key   = string

    email     = string
    password  = string

    # should be a UUID, generate using uuid.sh
    username  = string
  })
}

variable "app" {
  description       = "EyeLevel application information"
  type              = object({
    graph           = bool
    languages       = list(string)
    monitor         = bool
  })
  default           = {
    graph           = false
    languages       = ["en"]
    monitor         = false
  }
}

variable "app_internal" {
  description = "EyeLevel application internal information (do not change)"
  type        = object({
    namespace = string
    pv_class  = string
  })
  default     = {
    namespace = "eyelevel"
    pv_class  = "empty"
  }
}

variable "engines" {
  description        = "Completion engine configurations"
  type               = list(
    object(
      {
        apiKey       = string
        baseURL      = string
        engineID     = string
        maxRequests  = number
        maxTokens    = number
        requestLimit = number
        type         = string
        vision       = bool
      }
    )
  )
  default            = [
    {
      apiKey         = null
      baseURL        = null
      engineID       = "MiniCPM-V-2_6-int4"
      maxRequests    = 4
      maxTokens      = 10000000000
      requestLimit   = 4
      type           = null
      vision         = true
    }
  ]
}


# CACHE

variable "cache_existing" {
  description    = "Cache settings, if using an existing Redis cache outside of Kubernetes"
  type           = object({
    addr         = string
    is_instance  = bool
    port         = number
  })
  default        = {
    addr         = null
    is_instance  = null
    port         = null
  }
}

variable "cache_internal" {
  description        = "Redis internal settings"
  type               = object({
    image            = object({
      pull           = string
      repository     = string
      tag            = string
    })
    is_instance      = bool
    mount_path       = string
    operator_version = string
    port             = number
    service          = string
    version          = string
  })
  default            = {
    image            = {
      pull           = "Always"
      repository     = "public.ecr.aws/c9r4x6y5/eyelevel/redis"
      tag            = "latest"
    }
    is_instance      = true
    mount_path       = "/mnt/redis"
    operator_version = "v7.4.6-2"
    port             = 6379
    service          = "redis"
    version          = "6.1"
  }
}

variable "cache_resources" {
  description  = "Cache compute resource information"
  type         = object({
    replicas   = number
    resources  = object({
      limits   = object({
        cpu    = string
        memory = string
      })
      requests = object({
        cpu    = string
        memory = string
      })
    })
  })
  default      = {
    replicas   = 1
    resources  = {
      limits   = {
        cpu    = "2"
        memory = "4Gi"
      }
      requests = {
        cpu    = "2"
        memory = "4Gi"
      }
    }
  }
}


# DASHBOARD

variable "dashboard_internal" {
  description = "Web dashboard internal settings"
  type        = object({
    service   = string
  })
  default     = {
    service   = "dashboard"
  }
}


# DATABASE

variable "db" {
  description        = "Database service information"
  type               = object({
    db_name          = string
    db_password      = string
    db_root_password = string
    db_username      = string
  })
  default            = {
    db_name          = "eyelevel"
    db_password      = "password"
    db_root_password = "password"
    db_username      = "eyelevel"
  }
}

variable "db_existing" {
  description = "Database endpoint settings, if using an existing database outside of Kubernetes"
  type        = object({
    port      = number
    ro        = string
    rw        = string
  })
  default     = {
    port      = null
    ro        = null
    rw        = null
  }
}

variable "db_internal" {
  description             = "Database internal settings"
  type                    = object({
    backup                = bool
    chart                 = object({
      db                  = object({
        name              = string
        version           = string
      })
      operator            = object({
        name              = string
        version           = string
      })
      repository          = string
    })
    disable_unsafe_checks = bool
    ip_type               = string
    logcollector_enable   = bool
    pmm_enable            = bool
    port                  = number
    service               = string
    version               = string
  })
  default                 = {
    backup                = false
    chart                 = {
      db                  = {
        name              = "pxc-db"
        version           = "1.15.1"
      }
      operator            = {
        name              = "pxc-operator"
        version           = "1.15.1"
      }
      repository          = "https://percona.github.io/percona-helm-charts"
    }
    disable_unsafe_checks = true
    ip_type               = "ClusterIP"
    logcollector_enable   = false
    pmm_enable            = false
    port                  = 3306
    service               = "mysql"
    version               = "8.0"
  }
}

variable "db_resources" {
  description    = "Database compute resource information"
  type           = object({
    proxy        = object({
      replicas   = number
      resources  = object({
        limits   = object({
          cpu    = string
          memory = string
        })
        requests = object({
          cpu    = string
          memory = string
        })
      })
    })
    pv_size      = string
    replicas     = number
    resources    = object({
      limits     = object({
        cpu      = string
        memory   = string
      })
      requests   = object({
        cpu      = string
        memory   = string
      })
    })
  })
  default        = {
    proxy        = {
      replicas   = 1
      resources  = {
        limits   = {
          cpu    = "600m"
          memory = "1Gi"
        }
        requests = {
          cpu    = "600m"
          memory = "1Gi"
        }
      }
    }
    pv_size      = "20Gi"
    replicas     = 1
    resources    = {
      limits     = {
        cpu      = "600m"
        memory   = "1Gi"
      }
      requests   = {
        cpu      = "600m"
        memory   = "1Gi"
      }
    }
  }
}


# FILE

variable "file" {
  description     = "Database service information"
  type            = object({
    password      = string
    upload_bucket = string
    username      = string
  })
  default         = {
    password      = "minio123"
    upload_bucket = "eyelevel"
    username      = "minio"
  }
}

variable "file_existing" {
  description   = "MinIO settings, if using an existing MinIO instance outside of Kubernetes"
  type          = object({
    # no protocol
    base_domain = string

    bucket      = string
    password    = string
    port        = number
    ssl         = bool
    username    = string
  })
  default      = {
    base_domain = null
    bucket      = null
    password    = null
    port        = null
    ssl         = null
    username    = null
  }
}

variable "file_internal" {
  description        = "Database internal settings"
  type               = object({
    chart            = object({
      operator       = object({
        name         = string
        version      = string
      })
      repository     = string
      tenant         = object({
        name         = string
        version      = string
      })
    })
    port             = number
    pv_access        = string
    service          = string
    version          = string
  })
  default            = {
    chart            = {
      operator       = {
        name         = "operator"
        version      = "6.0.3"
      }
      repository     = "https://operator.min.io"
      tenant         = {
        name         = "tenant"
        version      = "6.0.3"
      }
    }
    port             = 9000
    pv_access        = "ReadWriteMany"
    service          = "minio"
    version          = "6.0.3"
  }
}

variable "file_resources" {
  description           = "Database compute resource information"
  type                  = object({
    operator            = object({
      replicas          = number
    })
    pool_size           = string
    pool_servers        = number
    pool_server_volumes = number
    pv_path             = string
    resources           = object({
      limits            = object({
        cpu             = string
        memory          = string
      })
      requests          = object({
        cpu             = string
        memory          = string
      })
    })
    ssl                 = bool
  })
  default               = {
    operator            = {
      replicas          = 1
    }
    pool_size           = "50Gi"
    pool_servers        = 1
    pool_server_volumes = 1
    pv_path             = "/Users/USER/mnt/minio"
    resources           = {
      limits            = {
        cpu             = "4"
        memory          = "8Gi"
      }
      requests          = {
        cpu             = "2"
        memory          = "4Gi"
      }
    }
    ssl                 = false
  }
}


# GRAPH

variable "graph_existing" {
  description    = "Graph settings, if using an existing neo4j graph DB outside of Kubernetes"
  type           = object({
    addr         = string
    port         = number
  })
  default        = {
    addr         = null
    port         = null
  }
}

variable "graph_internal" {
  description        = "Neo4j internal settings"
  type               = object({
    chart        = object({
      name       = string
      url        = string
      version    = string
    })
    service          = string
  })
  default            = {
    chart            = {
      name           = "neo4j"
      url            = "https://helm.neo4j.com/neo4j"
      version        = "5.24.1"
    }
    service          = "neo4j"
  }
}

variable "graph_resources" {
  description  = "Graph compute resource information"
  type         = object({
    replicas   = number
    resources  = object({
      limits   = object({
        cpu    = string
        memory = string
      })
      requests = object({
        cpu    = string
        memory = string
      })
    })
  })
  default      = {
    replicas   = 1
    resources  = {
      limits   = {
        cpu    = "1"
        memory = "4Gi"
      }
      requests = {
        cpu    = "0.5"
        memory = "2Gi"
      }
    }
  }
}


# GROUNDX

variable "groundx" {
  description     = "GroundX service information"
  type            = object({
    load_balancer = object({
      port        = number
    })
  })
  default         = {
    load_balancer = {
      port        = 80
    }
  }
}

variable "groundx_internal" {
  description    = "GroundX internal settings"
  type           = object({
    image        = object({
      pull       = string
      repository = string
      tag        = string
    })
    service      = string
    # all or search
    type         = string
    version      = string
  })
  default        = {
    image        = {
      pull       = "Always"
      repository = "public.ecr.aws/c9r4x6y5/eyelevel/groundx"
      tag        = "latest"
    }
    service      = "groundx"
    type         = "all"
    version      = "0.0.1"
  }
}


# LAYOUT

variable "layout" {
  type            = object({
    ocr           = object({
      credentials   = string
      project       = string
      type          = string
    })
  })
  default         = {
    ocr           = {
      credentials   = "gcv_credentials.json"
      project       = ""
      type          = "google"
    }
  }
  validation {
    condition     = var.layout.ocr.type != "google" || var.layout.ocr.project != ""
    error_message = "Project must be set if using Google OCR"
  }
}

variable "layout_internal" {
  description    = "Layout internal settings"
  type           = object({
    api            = object({
      image        = object({
        pull       = string
        repository = string
        tag        = string
      })
    })
    inference      = object({
      image        = object({
        pull       = string
        repository = string
        tag        = string
      })
      image_op     = object({
        pull       = string
        repository = string
        tag        = string
      })
    })
    models         = object({
      device     = string
    })
    process        = object({
      image        = object({
        pull       = string
        repository = string
        tag        = string
      })
    })
    service        = string
    version        = string
  })
  default          = {
    api            = {
      image        = {
        pull       = "Always"
        repository = "public.ecr.aws/c9r4x6y5/eyelevel/python-api"
        tag        = "latest"
      }
    }
    inference      = {
      image        = {
        pull       = "Always"
        repository = "public.ecr.aws/c9r4x6y5/eyelevel/layout-inference"
        tag        = "latest"
      }
      image_op     = {
        pull       = "Always"
        repository = "public.ecr.aws/c9r4x6y5/eyelevel/layout-inference-op"
        tag        = "latest"
      }
    }
    models         = {
      device       = "cuda"
    }
    process        = {
      image        = {
        pull       = "Always"
        repository = "public.ecr.aws/c9r4x6y5/eyelevel/layout-process"
        tag        = "latest"
      }
    }
    service        = "layout"
    version        = "0.0.1"
  }
}

variable "layout_resources" {
  description   = "Layout compute resource information"
  type           = object({
    api          = object({
      replicas   = number
      resources  = object({
        limits   = object({
          cpu    = string
          memory = string
        })
        requests = object({
          cpu    = string
          memory = string
        })
      })
      threads    = number
      workers    = number
    })
    inference    = object({
      replicas   = number
      resources  = object({
        limits   = object({
          cpu    = string
          memory = string
          gpu    = number
        })
        requests = object({
          cpu    = string
          memory = string
          gpu    = number
        })
      })
      workers    = number
    })
  })
  default     = {
    api          = {
      replicas   = 1
      resources  = {
        limits   = {
          cpu    = "1"
          memory = "1Gi"
        }
        requests = {
          cpu    = "0.5"
          memory = "500Mi"
        }
      }
      threads    = 2
      workers    = 2
    }
    inference    = {
      replicas   = 1
      resources  = {
        limits   = {
          cpu    = "3"
          memory = "12Gi"
          gpu    = 1
        }
        requests = {
          cpu    = "2"
          memory = "8Gi"
          gpu    = 1
        }
      }
      workers    = 4
    }
  }
}


# LAYOUT WEBHOOK

variable "layout_webhook_internal" {
  description    = "Layout webhook internal settings"
  type           = object({
    image        = object({
      pull       = string
      repository = string
      tag        = string
    })
    service      = string
    version      = string
  })
  default        = {
    image        = {
      pull       = "Always"
      repository = "public.ecr.aws/c9r4x6y5/eyelevel/layout-webhook"
      tag        = "latest"
    }
    service      = "layout-webhook"
    version      = "0.0.1"
  }
}


# MONITOR

variable "monitor_internal" {
  description = ""
  type        = object({
    adapter   = object({
      name    = string
      url     = string
    })
    chart     = object({
      name    = string
      url     = string
    })
    namespace = string
    redis     = object({
      name    = string
      url     = string
    })
    service   = string
  })
  default     = {
    adapter   = {
      name    = "prometheus-adapter"
      url     = "https://prometheus-community.github.io/helm-charts"
    }
    chart     = {
      name    = "prometheus"
      url     = "https://prometheus-community.github.io/helm-charts"
    }
    namespace = "eyelevel-monitor"
    redis     = {
      name    = "prometheus-redis-exporter"
      url     = "https://prometheus-community.github.io/helm-charts"
    }
    service   = "monitor"
  }
}


# PRE-PROCESS

variable "pre_process_internal" {
  description    = "Pre-Process internal settings"
  type           = object({
    image        = object({
      pull       = string
      repository = string
      tag        = string
    })
    service      = string
    version      = string
  })
  default        = {
    image        = {
      pull       = "Always"
      repository = "public.ecr.aws/c9r4x6y5/eyelevel/pre-process"
      tag        = "latest"
    }
    service      = "pre-process"
    version      = "0.0.1"
  }
}


# PROCESS

variable "process_internal" {
  description    = "Process internal settings"
  type           = object({
    image        = object({
      pull       = string
      repository = string
      tag        = string
    })
    service      = string
    version      = string
  })
  default        = {
    image        = {
      pull       = "Always"
      repository = "public.ecr.aws/c9r4x6y5/eyelevel/process"
      tag        = "latest"
    }
    service      = "process"
    version      = "0.0.1"
  }
}


# QUEUE

variable "queue_internal" {
  description    = "Queue internal settings"
  type           = object({
    image        = object({
      pull       = string
      repository = string
      tag        = string
    })
    service      = string
    version      = string
  })
  default        = {
    image        = {
      pull       = "Always"
      repository = "public.ecr.aws/c9r4x6y5/eyelevel/queue"
      tag        = "latest"
    }
    service      = "queue"
    version      = "0.0.1"
  }
}


# RANKER

variable "ranker_internal" {
  description    = "Ranker internal settings"
  type           = object({
    api            = object({
      image        = object({
        pull       = string
        repository = string
        tag        = string
      })
    })
    inference      = object({
      device       = string
      image        = object({
        pull       = string
        repository = string
        tag        = string
      })
      image_op     = object({
        pull       = string
        repository = string
        tag        = string
      })
    })
    service        = string
    version        = string
  })
  default        = {
    api            = {
      image        = {
        pull       = "Always"
        repository = "public.ecr.aws/c9r4x6y5/eyelevel/python-api"
        tag        = "latest"
      }
    }
    inference      = {
      device       = "cuda"
      image        = {
        pull       = "Always"
        repository = "public.ecr.aws/c9r4x6y5/eyelevel/ranker-inference"
        tag        = "latest"
      }
      image_op     = {
        pull       = "Always"
        repository = "public.ecr.aws/c9r4x6y5/eyelevel/ranker-inference-op"
        tag        = "latest"
      }
    }
    service        = "ranker"
    version        = "0.0.1"
  }
}

variable "ranker_resources" {
  description   = "Ranker compute resource information"
  type           = object({
    api          = object({
      replicas   = number
      resources  = object({
        limits   = object({
          cpu    = string
          memory = string
        })
        requests = object({
          cpu    = string
          memory = string
        })
      })
      threads    = number
      workers    = number
    })
    inference    = object({
      replicas   = number
      resources  = object({
        limits   = object({
          cpu    = string
          memory = string
          gpu    = number
        })
        requests = object({
          cpu    = string
          memory = string
          gpu    = number
        })
      })
      workers    = number
    })
  })
  default        = {
    api          = {
      replicas   = 1
      resources  = {
        limits   = {
          cpu    = "1"
          memory = "1Gi"
        }
        requests = {
          cpu    = "0.5"
          memory = "500Mi"
        }
      }
      threads    = 2
      workers    = 2
    }
    inference    = {
      replicas   = 3
      resources  = {
        limits   = {
          cpu    = "3"
          memory = "14Gi"
          gpu    = 1
        }
        requests = {
          cpu    = "2"
          memory = "10Gi"
          gpu    = 1
        }
      }
      workers    = 14
    }
  }
}


# SEARCH

variable "search" {
  description     = "Search service information"
  type            = object({
    index         = string
    password      = string
    plugins       = object({
      enabled     = bool
      installList = list(string)
    })
    root_password = string
    user          = string
  })
  default         = {
    index         = "prod-1"
    password      = "R0otb_*t!kazs"
    plugins       = {
      enabled     = false
      installList = []
    }
    root_password = "R0otb_*t!kazs"
    user          = "eyelevel"
  }
}

variable "search_existing" {
  description = "Search settings, if using an existing OpenSearch instance outside of Kubernetes"
  type            = object({
    # no protocol, no port
    base_domain   = string

    # includes protocol and port
    base_url      = string

    port          = number
  })
  default         = {
    base_domain   = null
    base_url      = null
    port          = null
  }
}

variable "search_internal" {
  description    = "Search internal settings"
  type           = object({
    chart        = object({
      name       = string
      url        = string
      version    = string
    })
    image        = object({
      name       = string
      repository = string
      tag        = string
    })
    port         = number
    service      = string
    version      = string
  })
  default        = {
    chart        = {
      name       = "opensearch"
      url        = "https://opensearch-project.github.io/helm-charts"
      version    = "2.23.1"
    }
    image        = {
      name       = "eyelevel/opensearch"
      repository = "public.ecr.aws/c9r4x6y5"
      tag        = "latest"
    }
    port         = 9200
    service      = "opensearch"
    version      = "2.16.0"
  }
}

variable "search_resources" {
  description     = "Search compute resource information"
  type            = object({
    pv_size       = string
    replicas      = number
    resources     = object({
      requests    = object({
        cpu       = string
        memory    = string
      })
    })
  })
  default         = {
    pv_size       = "20Gi"
    replicas      = 1
    resources     = {
      requests    = {
        cpu       = "1"
        memory    = "512Mi"
      }
    }
  }
}


# STREAM

variable "stream_base_url" {
  description = "Kafka base URL, if using an existing Kafka instance outside of Kubernetes"
  nullable    = true
  type        = string
  default     = null
}

variable "stream_existing" {
  description = "Stream settings, if using an existing Kafka instance outside of Kubernetes"
  type            = object({
    # no protocol, no port
    base_domain   = string

    # includes protocol and port
    base_url      = string

    port          = number
  })
  default         = {
    base_domain   = null
    base_url      = null
    port          = null
  }
}

variable "stream_internal" {
  description = "Stream internal settings"
  type        = object({
    chart     = object({
      name    = string
      url     = string
      version = string
    })
    
    port      = number
    service   = string
    version   = string
  })
  default     = {
    chart     = {
      name    = ""
      url     = "oci://quay.io/strimzi-helm/strimzi-kafka-operator"
      version = "0.35.0"
    }
    port      = 9092
    service   = "kafka"
    version   = "3.4.0"
  }
}

variable "stream_resources" {
  description       = "Stream compute resource information"
  type              = object({
    operator        = object({
      replicas      = number
    })
    partitions      = number
    resources       = object({
      limits        = object({
        cpu         = string
        memory      = string
      })
      requests      = object({
        cpu         = string
        memory      = string
      })
    })
    retention_bytes = number
    segment_bytes   = number
    service         = object({
      replicas      = number
      storage       = string
    })
    zookeeper       = object({
      replicas      = number
      storage       = string
    })
  })
  default           = {
    operator        = {
      replicas      = 1
    }
    partitions      = 3
    resources       = {
      limits        = {
        cpu         = "2"
        memory      = "4Gi"
      }
      requests      = {
        cpu         = "1"
        memory      = "2Gi"
      }
    }
    retention_bytes = 1073741824
    segment_bytes   = 1073741824
    service         = {
      replicas      = 2
      storage       = "10Gi"
    }
    zookeeper       = {
      replicas      = 1
      storage       = "5Gi"
    }
  }
}


# SUMMARY

variable "summary_existing" {
  description = "Summary settings, if using OpenAI vs private hosted model"
  nullable    = true
  type        = object({
    api_key   = string
    base_url  = string
  })
  default     = {
    api_key   = null
    base_url  = null
  }
}

variable "summary_internal" {
  description    = "Summary internal settings"
  type           = object({
    api            = object({
      image        = object({
        pull       = string
        repository = string
        tag        = string
      })
    })
    inference      = object({
      device       = string
      image        = object({
        pull       = string
        repository = string
        tag        = string
      })
      image_op     = object({
        pull       = string
        repository = string
        tag        = string
      })
    })
    service        = string
    version        = string
  })
  default        = {
    api            = {
      image        = {
        pull       = "Always"
        repository = "public.ecr.aws/c9r4x6y5/eyelevel/python-api"
        tag        = "latest"
      }
    }
    inference      = {
      device       = "cuda"
      image        = {
        pull       = "Always"
        repository = "public.ecr.aws/c9r4x6y5/eyelevel/summary-inference"
        tag        = "latest"
      }
      image_op     = {
        pull       = "Always"
        repository = "public.ecr.aws/c9r4x6y5/eyelevel/summary-inference-op"
        tag        = "latest"
      }
    }
    service        = "summary"
    version        = "0.0.1"
  }
}

variable "summary_resources" {
  description    = "Summary compute resource information"
  type           = object({
    api          = object({
      replicas   = number
      resources  = object({
        limits   = object({
          cpu    = string
          memory = string
        })
        requests = object({
          cpu    = string
          memory = string
        })
      })
      threads    = number
      workers    = number
    })
    inference    = object({
      replicas   = number
      resources  = object({
        limits   = object({
          cpu    = string
          memory = string
          gpu    = number
        })
        requests = object({
          cpu    = string
          memory = string
          gpu    = number
        })
      })
      threads    = number
      workers    = number
    })
  })
  default        = {
    api          = {
      replicas   = 1
      resources  = {
        limits   = {
          cpu    = "2"
          memory = "1Gi"
        }
        requests = {
          cpu    = "1"
          memory = "500Mi"
        }
      }
      threads    = 3
      workers    = 2
    }
    inference    = {
      replicas   = 2
      resources  = {
        limits   = {
          cpu    = "3"
          memory = "14Gi"
          gpu    = 1
        }
        requests = {
          cpu    = "2"
          memory = "10Gi"
          gpu    = 1
        }
      }
      threads    = 1
      workers    = 2
    }
  }
}


# SUMMARY CLIENT

variable "summary_client_internal" {
  description    = "Summary client internal settings"
  type           = object({
    image        = object({
      pull       = string
      repository = string
      tag        = string
    })
    service      = string
    version      = string
  })
  default        = {
    image        = {
      pull       = "Always"
      repository = "public.ecr.aws/c9r4x6y5/eyelevel/summary-client"
      tag        = "latest"
    }
    service      = "summary-client"
    version      = "0.0.1"
  }
}

variable "summary_client_resources" {
  description  = "Summary client compute resource information"
  type         = object({
    replicas   = number
    resources  = object({
      limits   = object({
        cpu    = string
        memory = string
      })
      requests = object({
        cpu    = string
        memory = string
      })
    })
    threads    = number
  })
  default      = {
    replicas   = 1
    resources  = {
      limits   = {
        cpu    = "1"
        memory = "2Gi"
      }
      requests = {
        cpu    = "0.5"
        memory = "500Mi"
      }
    }
    threads    = 2
  }
}


# UPLOAD

variable "upload_internal" {
  description    = "Upload client internal settings"
  type           = object({
    image        = object({
      pull       = string
      repository = string
      tag        = string
    })
    service      = string
    version      = string
  })
  default        = {
    image        = {
      pull       = "Always"
      repository = "public.ecr.aws/c9r4x6y5/eyelevel/upload"
      tag        = "latest"
    }
    service      = "upload"
    version      = "0.0.1"
  }
}