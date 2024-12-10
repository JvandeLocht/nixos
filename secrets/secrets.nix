let
  jan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJn9cBaz3tYq1veuROlicKBNW4ArJTJ3lEk10+SN+x7V";
  users = [ jan ];

  nixnas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGL4k+0jwQGQyhIgEht3P+J4sCbVNdhnmAAzSqyuYY0t";
  groot = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGxH8LRSNnFDsZ516bzdADxRR6MY2UZOrvh/7inTe2NH";
  systems = [ groot nixnas ];
in
{
  "minio-accessKey.age".publicKeys = users ++ systems;
  "minio-secretKey.age".publicKeys = users ++ systems;
  "jan-nixnas.age".publicKeys = users ++ systems;
  "jan-nixnas-borg.age".publicKeys = users ++ systems;
  "rclone-config.age".publicKeys = users ++ systems;
  "jan-nixnas-restic.age".publicKeys = users ++ systems;
  "jan-groot-restic.age".publicKeys = users ++ systems;
}
