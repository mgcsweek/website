HOSTNAME ?= csweek
SCSS_FLAGS ?= --style=expanded --sourcemap=inline

default:
	find . -name '*.moon' | grep -v '^./spec/' | xargs moonc
	sass --scss $(SCSS_FLAGS) scss/style.scss static/style.css
	sass --scss $(SCSS_FLAGS) scss/security.scss static/security.css

production:
	SCSS_FLAGS="--style=compressed --sourcemap=none" make

test:
	cd spec && busted .

push:
	git checkout develop
	git push
	git checkout master
	git merge develop
	git push
	git checkout develop
	ssh -t $(HOSTNAME) 'sudo systemctl start git-pull && echo "Pulled successfully."'
