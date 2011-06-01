set -e
git checkout twilio-deploy 
git merge master
git pull heroku master
git push heroku twilio-deploy:master
git checkout master
