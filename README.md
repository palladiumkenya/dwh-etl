# dwh-etl
dwapi-etl


# SQLFluff
SQLFluff is an open source, dialect-flexible and configurable SQL linter. Designed with ELT applications in mind, SQLFluff also works with Jinja templating and dbt. SQLFluff will auto-fix most linting errors, allowing you to focus your time on what matters. More documentation at: https://sqlfluff.com/

## Setting up sqlfluff
 ## Requirements
- Make sure you have python 3.8 or higher

### Setup
- Create a virtual python virtual environment by runing python3.8 -m venv <name_of_environemt> (e.g. `python3.8 -m venv venv`)
- Activate virtual environment by running: source venv/Scripts/activate
- Install the following packages by running:
    - pip install sqlfluff
    - pip install pre-commit

- Run `pre-commit install` to to set up the git hook scripts in the config file `.pre-commit-config.yaml

### Maintainance of the rules
The linting and fixing of the sql files is controlled by the config file `Scripts/.sqlfluff` 
You can edit or add new rules on this file. The various rules can be found at https://docs.sqlfluff.com/en/2.1.3/rules.html#

### Usage
On running your commit message, sqlfluff will run a lint and fix for any .sql files changed 