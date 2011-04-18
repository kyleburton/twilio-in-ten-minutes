set -e
git checkout twilio-deploy 
git rebase master
git pull --rebase heroku master
git push heroku twilio-deploy:master
git checkout master
