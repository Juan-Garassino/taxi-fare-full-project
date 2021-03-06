# ----------------------------------
#          INSTALL & TEST
# ----------------------------------
install_requirements:
	@pip install -r requirements.txt

check_code:
	@flake8 scripts/* MinTrainer/*.py

black:
	@black scripts/* MinTrainer/*.py

test:
	@coverage run -m pytest tests/*.py
	@coverage report -m --omit=$(VIRTUAL_ENV)/lib/python*

ftest:
	@Write me

clean:
	@rm -f */version.txt
	@rm -f .coverage
	@rm -fr */__pycache__ */*.pyc __pycache__
	@rm -fr build dist
	@rm -fr MinTrainer-*.dist-info
	@rm -fr MinTrainer.egg-info

install:
	@pip install . -U

all: clean install test black check_code


uninstal:
	@python setup.py install --record files.txt
	@cat files.txt | xargs rm -rf
	@rm -f files.txt

count_lines:
	@find ./ -name '*.py' -exec  wc -l {} \; | sort -n| awk \
        '{printf "%4s %s\n", $$1, $$2}{s+=$$0}END{print s}'
	@echo ''
	@find ./scripts -name '*-*' -exec  wc -l {} \; | sort -n| awk \
		        '{printf "%4s %s\n", $$1, $$2}{s+=$$0}END{print s}'
	@echo ''
	@find ./tests -name '*.py' -exec  wc -l {} \; | sort -n| awk \
        '{printf "%4s %s\n", $$1, $$2}{s+=$$0}END{print s}'
	@echo ''

# ----------------------------------
#      UPLOAD PACKAGE TO PYPI
# ----------------------------------
build:
	@python setup.py sdist bdist_wheel

pypi_test:
	@twine upload -r testpypi dist/* -u lologibus2

pypi:
	@twine upload dist/* -u lologibus2


# ----------------------------------
#      TRAIN MODEL
# ----------------------------------

run_locally:
	python -m MinTrainer.trainer

# bucket
BUCKET_NAME=le-wagon-data

# training folder
BUCKET_TRAINING_FOLDER=trainings

# training params
REGION=europe-west1

# app environment
PYTHON_VERSION=3.7
FRAMEWORK=scikit-learn
RUNTIME_VERSION=2.2

# package params
PACKAGE_NAME=MinTrainer
FILENAME=trainer

# pred
# PRED_FILENAME=predict

##### Job - - - - - - - - - - - - - - - - - - - - - - - - -

JOB_NAME=mintrainer_$(shell date +'%Y%m%d_%H%M%S')

gcp_submit_training:
	gcloud ai-platform jobs submit training ${JOB_NAME} \
		--job-dir gs://${BUCKET_NAME}/${BUCKET_TRAINING_FOLDER} \
		--package-path ${PACKAGE_NAME} \
		--module-name ${PACKAGE_NAME}.${FILENAME} \
		--python-version=${PYTHON_VERSION} \
		--runtime-version=${RUNTIME_VERSION} \
		--region ${REGION} \
		--stream-logs

# ----------------------------------
#      RUN API
# ----------------------------------

run_api:
	python app.py
