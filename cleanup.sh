docker container rm permtest
docker system prune
git gc
sudo find ./ -iname *.un~ -exec rm {} \;
