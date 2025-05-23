let
  jan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJn9cBaz3tYq1veuROlicKBNW4ArJTJ3lEk10+SN+x7V";
  users = [ jan ];

  nixnas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGL4k+0jwQGQyhIgEht3P+J4sCbVNdhnmAAzSqyuYY0t";
  groot = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE7rAX3mGpyCpMpAt6uCxKWhcc5Z0S7e6ayrKfppRfj0";
  nixwsl = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN8RFuq/2+w8kisp9KOWbVKEXIXsR0QWianZY2DERaum";
  systems = [
    groot
    nixnas
  ];
in
{
  "minio-accessKey.age".publicKeys = users ++ [ nixnas ];
  "minio-secretKey.age".publicKeys = users ++ [ nixnas ];
  "jan-nixnas.age".publicKeys = users ++ [ nixnas ];
  "rclone-config.age".publicKeys = users ++ systems;
  "backrest-nixnas.age".publicKeys = users ++ [ nixnas ];
  "backrest-groot.age".publicKeys = users ++ [ groot ];
  "smb-secrets.age".publicKeys = users ++ [ groot ];
  "bitwarden.age".publicKeys = users ++ [ groot ];
}
