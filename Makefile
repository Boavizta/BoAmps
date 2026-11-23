livedocs: install-deps ## Serve the docs locally
	cd doc; poetry run mkdocs serve --livereload

install-deps: install-poetry
	poetry install --no-root --with doc

install-poetry:
	pipx install poetry
