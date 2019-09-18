until worldserver; do
    echo "Server 'worldserver' crashed with exit code $?.  Respawning.." >&2
    sleep 1
done