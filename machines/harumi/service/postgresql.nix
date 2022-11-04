{

  services.postgresql.settings = {

      # Generated using PGTune

      max_connections = 500;
      shared_buffers = "8GB";
      effective_cache_size = "24GB";
      maintenance_work_mem = "2GB";
      checkpoint_completion_target = 0.9;
      wal_buffers = "16MB";
      default_statistics_target = 100;
      random_page_cost = 1.1;
      effective_io_concurrency = 100;
      work_mem = "699kB";
      min_wal_size = "1GB";
      max_wal_size = "4GB";
      max_worker_processes = 17;
      max_parallel_workers_per_gather = 4;
      max_parallel_workers = 17;
      max_parallel_maintenance_workers = 4;

      # Others

      full_page_writes = "off";
    };

}
