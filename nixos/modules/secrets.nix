{
  age.secrets = {
    minio = {
      file = ../../secrets/minio.age;
      path = "/persist/secrets/minio";
      symlink = false;
    };
    jan-nixnas = {
      file = ../../secrets/jan-nixnas.age;
      path = "/persist/secrets/jan-nixnas";
      symlink = false;
    };
  };
}
