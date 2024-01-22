# CICD notes

What it should be - easy to use, automatic deployment (developer only uploads code, all affected modules get updated in their respective robots/folders automatically)
Security - do not want to reveal any passwords, test data, invoice numbers, vault secret names etc...
Expandable - (infinite) multiple robots using same modules, no limitations on user count or such
Manageable - expanding and maintaining currently deployed objects should not be time-consuming and unreliable
Uptime - as much as possible, any downtime here would be extra steps to take and such. Dont want to deal with code not updating, this pipeline should work all the time with as few errors as possible

Some generic info links:
https://docs.robotframework.org/docs/using_rf_in_ci_systems/ci
https://docs.robotframework.org/docs/getting_started/testing
https://www.redhat.com/en/topics/devops/what-is-ci-cd

## Possible solutions, frameworks

### Jenkins

https://docs.robotframework.org/docs/using_rf_in_ci_systems/ci/jenkins

Open source, widely used. Configurable as needed. Main unit of work is "jobs" - some preconfigured pipeline commands that act as kind of sh/Linux commands.

Possible problems: needs a different architecture for running our robots, because a Jenkins agent runs robots by steps (e.g. queue and then work). Currently, robots are in control room and would like to NOT change that.

These configurations don't seem that simple, so seems like a lot of work to get done correctly aswell. Time investment is considerable here (setup takes time and software is complicated, and we also have eto rewrite all robots anyway). 

Conclusion: not a very practical solution, but very sandbox and configurable

### PyPi (PIP)

https://pypi.org/
https://docs.readthedocs.io/en/stable/guides/private-python-packages.html

Widely used, very common and massive database of libraries.
Already in use in robots for modules
Base principle very simple - a collection of custom modules that can be installed in python using their web API to download the requested version of module.

Problems: SECURITY. Biggest flaw here - github repository will be public and all code visible. This means exposed inner workings, not good. There is a workaround (2nd link), but it uses tokens and such - is it a good solution, if we connect 2+ computers with multiple different IPs. Will have to test.

Robot Framework syntax could be an issue here - could be some limitations on uploading to python packages with files that contain RF keywords only. (Something like compile fails or something along those lines)

Documentation and organization of files will be difficult aswell with this - our github documentation will have to be pretty minimal and definitely "safe", as it would be pretty public. Also where everything is and what tokens are used where etc, have to think.

Conclusion: seems like the best option, if we find a way to make it private. In theory

### Poetry

https://python-poetry.org/docs/basic-usage/

Very similiar to pip, it basically is pip but with some fancier functionality.
Basically a tool to package a full project and build it depending on configured dependencies.

How it works: kind of similiar to something like docker. Makes a package that contains all dependencies etc so it will work on any machine as intended. We could then update that package somewhere and all good.

Problems: extra step on every development cycle, as we have to manage these new packages now. After each code update, re-build package and re-upload. With PyPi we could just update required module and if our yaml is set to latest version, should update automatically everywhere.

Conclusion: if PyPi is not enough and we need something more fool-proof and pre-complete but more tedious and time-consuming, then this seems to be the correct choice

### Azure DevOps integration

https://github.com/robocorp/example-advanced-python-template/tree/main/ci_cd/azure_devops

Used for running robots from Azure - might be a relevant solution/idea later

