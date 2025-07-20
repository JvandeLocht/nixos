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
    smb-secrets = {
      file = ../../secrets/smb-secrets.age;
      path = "/persist/secrets/smb-secrets";
      symlink = false;
    };
    bitwarden = {
      file = ../../secrets/bitwarden.age;
      path = "/persist/secrets/bitwarden";
      symlink = false;
    };
    filen-webdav-user = {
      file = ../../secrets/filen-webdav-user.age;
      path = "/persist/secrets/filen-webdav-user";
      symlink = false;
    };
    filen-webdav-password = {
      file = ../../secrets/filen-webdav-password.age;
      path = "/persist/secrets/filen-webdav-password";
      symlink = false;
    };
    filen-cli = {
      file = ../../secrets/filen-cli.age;
      path = "/persist/filen/.filen-cli-auth-config";
      symlink = false;
      mode = "600";
      owner = "filen";
      group = "users";
    };
    # rclone-config = {
    #   file = ../../secrets/rclone-config.age;
    #   path = "/persist/secrets/rclone-config";
    #   symlink = false;
    # };
    # backrest-nixnas = {
    #   file = ../../secrets/backrest-nixnas.age;
    #   path = "/persist/secrets/backrest-nixnas";
    #   symlink = false;
    # };
    # backrest-groot = {
    #   file = ../../secrets/backrest-groot.age;
    #   path = "/persist/secrets/backrest-groot";
    #   symlink = false;
    # };
  };
}
