# dwh-etl
dwapi-etl

# Setting up sqlfluff
 ## Requirements
    - Make sure you have python 3.8 or higher

## Setup
    - Create a virtual python virtual environment by runing python3.8 -m venv <name_of_environemt> (e.g. `python3.8 -m venv venv`)
    - Activate virtual environment by running: source venv/Scripts/activate
    - Install the following packages by running:
        - pip install sqlfluff
        - pip install pre-commit

    - Run `pre-commit install` to to set up the git hook scripts in the config file `.pre-commit-config.yaml