default:
	find . -name '*.moon' | grep -v '^./spec/' | xargs moonc
	sass --scss scss/style.scss static/style.css

test:
	cd spec && busted .
