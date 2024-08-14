# Stop and remove all running containers
Write-Host "Stopping all running containers..."
docker stop $(docker ps -q)

Write-Host "Removing all containers..."
docker rm $(docker ps -a -q)

# Remove all dangling images (unused images)
Write-Host "Removing dangling images..."
docker rmi $(docker images -f "dangling=true" -q)

# Remove all unused volumes
Write-Host "Removing unused volumes..."
docker volume rm $(docker volume ls -f "dangling=true" -q)

# Remove all networks not used by at least one container
Write-Host "Removing unused networks..."
docker network prune -f

# Remove all build cache
Write-Host "Cleaning up build cache..."
docker builder prune -f

Write-Host "Docker cleanup completed."
