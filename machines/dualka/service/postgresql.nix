{ services.postgresql.settings = {

  # Generated using PGTune

  max_connections = 200;
  shared_buffers = "256MB";
  effective_cache_size = "768MB";
  maintenance_work_mem = "64MB";
  checkpoint_completion_target = 0.9;
  wal_buffers = "7864kB";
  default_statistics_target = 100;
  random_page_cost = 1.1;
  effective_io_concurrency = 100;
  work_mem = "655kB";
  min_wal_size = "1GB";
  max_wal_size = "4GB";

  # Others

  full_page_writes = "off";

}; }
