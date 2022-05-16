.PHONY: kind network cluster cleanup

all: clean prune install kind

init: poetry install kind

poetry:
	poetry install

install:
	pip install --upgrade poetry pip >/dev/null 2>&1; \
	POETRY_PYTHON=$$(poetry env info -p); \
	poetry install --no-root; \
	poetry run ansible-galaxy collection install -r ansible/collections/requirements.yml; \
	ansible -m package -a 'name=bubblewrap' --become localhost >/dev/null 2>&1; \
	helm plugin install https://github.com/databus23/helm-diff 2>/dev/null || exit 0;

kind:
	poetry run ansible-playbook ansible/kind/install.yml

clean:
	POETRY_PYTHON=$$(poetry env info -p); \
	poetry run ansible-playbook ansible/kind/destroy.yml \
	-e ansible_python_interpreter=$$POETRY_PYTHON/bin/python

prune:
	poetry run ansible-playbook ansible/prune.yml;
