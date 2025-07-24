{
  age.secrets = {
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
