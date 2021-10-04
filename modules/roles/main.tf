
terraform {
  required_providers {
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "0.9.0"
    }
  }
}

resource "mongodbatlas_custom_db_role" "main" {
  project_id = var.atlasprojectid
  role_name  = "${var.app_name}-${var.environment}-dbAdmin"

  actions {
    action = "UPDATE"
    resources {
      collection_name = ""
      database_name   = "${var.app_name}-${var.environment}-db"
    }
  }
  actions {
    action = "INSERT"
    resources {
      collection_name = ""
      database_name   = "${var.app_name}-${var.environment}-db"
    }
  }
  actions {
    action = "REMOVE"
    resources {
      collection_name = ""
      database_name   = "${var.app_name}-${var.environment}-db"
    }
  }
  # actions {
  #   action = "FIND"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "BYPASS_DOCUMENT_VALIDATION"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "USE_UUID"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "CREATE_COLLECTION"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "CREATE_INDEX"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "DROP_COLLECTION"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "ENABLE_PROFILER"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "CHANGE_STREAM"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "COLL_MOD"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "COMPACT"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "DROP_DATABASE"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "DROP_INDEX"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "RE_INDEX"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "RENAME_COLLECTION_SAME_DB"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "CONVERT_TO_CAPPED"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "LIST_SESSIONS"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "KILL_ANY_SESSION"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "COLL_STATS"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "CONN_POOL_STATS"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "DB_HASH"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "DB_STATS"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "LIST_DATABASES"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "LIST_COLLECTIONS"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "LIST_INDEXES"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "SERVER_STATUS"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "VALIDATE"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "TOP"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "SQL_GET_SCHEMA"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "SQL_SET_SCHEMA"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "VIEW_ALL_HISTORY"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "OUT_TO_S3"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "STORAGE_GET_CONFIG"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
  # actions {
  #   action = "STORAGE_SET_CONFIG"
  #   resources {
  #     collection_name = ""
  #     database_name   = "${var.app_name}-${var.environment}-db"
  #   }
  # }
}
