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
    filen-webdav-user = {
      file = ../../secrets/filen-webdav-user.age;
      path = "/persist/filen/filen-webdav-user";
      symlink = false;
      mode = "600";
      owner = "filen";
      group = "users";
    };
    filen-webdav-password = {
      file = ../../secrets/filen-webdav-password.age;
      path = "/persist/filen/filen-webdav-password";
      symlink = false;
      mode = "600";
      owner = "filen";
      group = "users";
    };
    filen-cli = {
      file = ../../secrets/filen-cli.age;
      path = "/persist/filen/.filen-cli-auth-config";
      symlink = false;
      mode = "600";
      owner = "filen";
      group = "users";
    };
  };
}
