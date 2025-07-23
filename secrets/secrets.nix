let
  jan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJn9cBaz3tYq1veuROlicKBNW4ArJTJ3lEk10+SN+x7V";
  users = [jan];

  nixnas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPT2EdRcef9KqIJXl8iT65ioXh2oVPt4FmnwOQ+gh2cn";
  groot = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE7rAX3mGpyCpMpAt6uCxKWhcc5Z0S7e6ayrKfppRfj0";
  nixwsl = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN8RFuq/2+w8kisp9KOWbVKEXIXsR0QWianZY2DERaum";
  systems = [
    groot
    nixnas
  ];
in {
  "minio-accessKey.age".publicKeys = users ++ [nixnas];
  "minio-secretKey.age".publicKeys = users ++ [nixnas];
  "jan-nixnas.age".publicKeys = users ++ [nixnas];
  "filen-cli.age".publicKeys = users ++ systems;
  "filen-webdav-user.age".publicKeys = users ++ systems;
  "filen-webdav-password.age".publicKeys = users ++ systems;
  "backrest-nixnas.age".publicKeys = users ++ [nixnas];
  "smb-secrets.age".publicKeys = users ++ [groot];
}
