git checkout master
git pull
git branch -d $(git branch | awk 'NR==1 {print}')
