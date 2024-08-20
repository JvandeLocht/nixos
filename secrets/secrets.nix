let
  jan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJn9cBaz3tYq1veuROlicKBNW4ArJTJ3lEk10+SN+x7V";
  users = [ jan ];

  nixnas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGL4k+0jwQGQyhIgEht3P+J4sCbVNdhnmAAzSqyuYY0t";
  groot = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILQZs0W714LLPTGtKXdekCxrJfHxxB3XlMi45rOAspRu";
  systems = [ groot nixnas ];
in
{
  "minio.age".publicKeys = users ++ systems;
  "jan-nixnas.age".publicKeys = users ++ systems;
}
