MNG:=uv run python manage.py

.PHONY: server
server: .env
	@$(MNG) runserver

.PHONY: db
db:
	@$(MNG) migrate

requirements.txt: uv.lock
	@uv export --frozen --output-file=$@

.env: .env.example
	@test -r .env \
		&& echo "Your .env is older than .env.example" \
		|| cp .env.example .env
