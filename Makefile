HOSTNAME=csweek

default:
	find . -name '*.moon' | grep -v '^./spec/' | xargs moonc
	sass --scss scss/style.scss static/style.css

test:
	cd spec && busted .

push:
	git checkout develop
	git push
	git checkout master
	git merge develop
	git push
	git checkout develop
	ssh -t $(HOSTNAME) 'sudo systemctl start git-pull'
