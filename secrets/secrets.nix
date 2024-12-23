let
  jan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJn9cBaz3tYq1veuROlicKBNW4ArJTJ3lEk10+SN+x7V";
  users = [ jan ];

  nixnas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGL4k+0jwQGQyhIgEht3P+J4sCbVNdhnmAAzSqyuYY0t";
  groot = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE7rAX3mGpyCpMpAt6uCxKWhcc5Z0S7e6ayrKfppRfj0";
  systems = [ groot nixnas ];
in
{
  "minio-accessKey.age".publicKeys = users ++ nixnas;
  "minio-secretKey.age".publicKeys = users ++ nixnas;
  "jan-nixnas.age".publicKeys = users ++ nixnas;
  "rclone-config.age".publicKeys = users ++ systems;
  "jan-nixnas-restic.age".publicKeys = users ++ nixnas;
  "jan-groot-restic.age".publicKeys = users ++ groot;
  "backrest-nixnas.age".publicKeys = users ++ nixnas;
}
