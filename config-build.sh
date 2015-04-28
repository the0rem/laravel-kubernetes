#!/bin/bash

# Builds deployment yaml files using dev .env file injected


# Parse arguments
usage() {
    echo "Usage: $0 [-h] [-v] -e ENV"
    echo "  -h --help  Help. Display this message and quit."
    echo "  -v --version Version. Print version number and quit."
    echo "  -e --env Specify configuration file FILE."
    exit
}

containerEnvironmentsFile="env.yaml"
environment="dev"
templatesDir="${PWD}/templates"
environmentsDir="${PWD}/environments"
buildDir="${PWD}/dist"

echo $buildDir;

while (( $# > 0 ))
do
    option="$1"
    shift

    case $option in
    -h|--help)
        usage
        exit 0
        ;;
    -v|--version)
        echo "$0 version $version"
        exit 0
        ;;
    -e|--env)  # Example with an operand
        environment="$1"
        shift
        ;;
    -*)
        echo "Invalid option: '$opt'" >&2
        exit 1
        ;;
    *)
        # end of long options
        break;
        ;;
   esac

done



# Make sure build dir exists
[ -d ${buildDir} ] || mkdir -p ${buildDir}

# Make sure templates dir exists
if [ ! -d ${templatesDir} ]; then
	echo "Templates directory '${templatesDir}' not found" >&2
    exit 1
fi

# Make sure environments dir exists
if [ ! -d ${environmentsDir} ]; then
	echo "Environments directory '${environmentsDir}' not found" >&2
    exit 1
fi

# Make sure build dir exists
if [ ! -d ${buildDir} ]; then
	echo "Invalid option: '${buildDir}'" >&2
    exit 1
fi

# Make sure environments dir exists
if [ ! -d "${environmentsDir}/${environment}" ]; then
	echo "Environments directory '${environmentsDir}/${environment}' not found" >&2
    exit 1
fi

# Make sure environments env.yaml file exists
if [ ! -f "${environmentsDir}/${environment}/${containerEnvironmentsFile}" ]; then
	echo "Environments directory '${environmentsDir}/${environment}' not found" >&2
    exit 1
fi

envFile="${environmentsDir}/${environment}/${containerEnvironmentsFile}"
# cp -v $envFile $buildDir
# envFile="${buildDir}/${containerEnvironmentsFile}"
# sed -i 's/[\/&]/\\&/g' $envFile
# envData=cat $envFile

# Build any environmental pods first to make sure the data is ready for other pods
for file in $(find ${environmentsDir}/${environment} -exec echo '{}' \;); do 
    
    if [[ $file == *.yaml ]]; then
        cp -v $file $buildDir
    fi

done;

# Build tempaltes using environmental variables
for file in $(find ${templatesDir} -type f -exec echo '{}' \;); do 

    # cp -v $file $buildDir
    destinationFile="$buildDir/$(basename ${file})"

	# Inject env data into templates
	if [[ $destinationFile == *.yaml ]]; then
		# sed -i "s/{env}/${envData}/g" $destinationFile
        # cat dist/08-frontend-controller.yaml | sed -e '/env:/{r env.yaml' -e '}'
        spacing=egrep '(^\s).*#env#'

        cat $file | sed -e "/#env#/{r $envFile" -e "}" > $destinationFile

        sed -e '^'
	fi

done;

echo "Build complete!"