{
  age.secrets = {
    minio-accessKey = {
      file = ../../secrets/minio-accessKey.age;
      path = "/persist/secrets/minio-accessKey";
      symlink = false;
      mode = "770";
      owner = "jan";
      group = "users";
    };
    minio-secretKey = {
      file = ../../secrets/minio-secretKey.age;
      path = "/persist/secrets/minio-secretKey";
      symlink = false;
      mode = "770";
      owner = "jan";
      group = "users";
    };
    jan-nixnas = {
      file = ../../secrets/jan-nixnas.age;
      path = "/persist/secrets/jan-nixnas";
      symlink = false;
    };
    rclone-config = {
      file = ../../secrets/rclone-config.age;
      path = "/persist/secrets/rclone-config";
      symlink = false;
    };
    rclone-config-root = {
      file = ../../secrets/rclone-config.age;
      path = "/persist/secrets/rclone.conf";
      symlink = false;
    };
    jan-nixnas-restic = {
      file = ../../secrets/jan-nixnas-restic.age;
      path = "/persist/secrets/jan-nixnas-restic";
      symlink = false;
    };
    jan-groot-restic = {
      file = ../../secrets/jan-groot-restic.age;
      path = "/persist/secrets/jan-groot-restic";
      symlink = false;
    };
    backrest-nixnas = {
      file = ../../secrets/backrest-nixnas.age;
      path = "/persist/secrets/backrest-nixnas";
      symlink = false;
    };
  };
}
