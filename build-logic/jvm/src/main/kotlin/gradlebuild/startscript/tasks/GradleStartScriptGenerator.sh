#!/bin/sh
#
# This is a re-implementation (in Shell rather than Kotlin) of
# build-logic/jvm/src/main/kotlin/gradlebuild/startscript/tasks/GradleStartScriptGenerator.kt
#
# It's intended to be minimally sufficient to generate "gradlew" from the
# "unixStartScript" template, thus allowing "gradlew" to be supported and
# modified by persons skilled in the POSIX shell but without familiarity with
# or access to Kotlin's template system.
#
# In particular, this assumes it should:
#   - exclude any blocks that are dependent on "mainClassName"; but
#   - include all other conditional blocks.
#

app_name=${0##*/}
bin_dir=${0%"$app_name"}
top_dir=${bin_dir%build-logic/jvm/*}
top_dir=${top_dir%.git*}

################################################################################

# Settings copied from Gradle project configuration

  appHomeRelativePath=
appNameSystemProperty=org.gradle.appname
      applicationName=Gradle
            classpath='$APP_HOME/gradle/wrapper/gradle-wrapper.jar'
       defaultJvmOpts='-Dfile.encoding=UTF-8 "-Xmx64m" "-Xms64m"'
        mainClassName=org.gradle.wrapper.GradleWrapperMain
           modulePath=
   optsEnvironmentVar=GRADLE_OPTS

################################################################################

gradle_path=${top_dir}gradlew
template_path=${top_dir}platforms/jvm/plugins-application/src/main/resources/org/gradle/api/internal/plugins/unixStartScript.txt

################################################################################

mode=OUTPUT
target=
template=

case $app_name in
    (*check* | *compare*)   mode=COMPARE ;;
    (*gen*)                 mode=REPLACE ;;
    (*)                     mode=OUTPUT ;;
esac

while :; do
    case $1 in
        (-c | --compare)    mode=COMPARE ;;
        (-r | --replace)    mode=REPLACE ;;
        (-o | --output)     mode=OUTPUT ;;
        (-s | --source)     template=$2 ; shift ;;
             (--source=*)   template=${1#*=} ;;
        (-s?*)              template=${1#-?} ;;
        (-t | --target)     target=$2 ; shift ;;
        (-t?*)              target=${1#-?} ;;
             (--target=*)   target=${1#*=} ;;
        (-h | --help)       cat <<-EndOfHelp ; exit 0 ;;
				$app_name [-c|-g|-o]
				    -c --compare        Compare current version with generated version
				    -g --generate       Overwrite current version with generated version
				    -o --output         Output generated version
				    -s --source=FILE    Specify source template
				    -t --target=FILE    Specify target to replace or compare
				    --help
				EndOfHelp
        (-?*)               printf >&2 'Invalid option "%s"; try %s --help\n' "$1" "$app_name"
                            exit 64 ;;
        (*) break ;;
    esac
    shift
done

if [ -z "$template" ] && [ $# != 0 ]
then
    template=$1
    shift
fi
_=${template:=$template_path}

if [ -z "$target" ] && [ "$mode" != OUTPUT ] && [ $# != 0 ]
then
    target=$1
    shift
fi
_=${target:=$gradle_path}

[ $# = 0 ] || {
    printf >&2 '%s Too many args\n' "$app_name"
    exit 64
}

################################################################################

defaultJvmOpts="'$defaultJvmOpts'"

s='cat <<EoUSS
'$( sed 's/[`]/\\&/g' < "$template" )'
EoUSS'

generate() {
    eval "$s" |
    sed -e '
            1  h;
            1! H;
            $! d;
            g;
            s@<%\n* */\*\([^*]\|\n\|\*\**[^/*]\)*\*/\n* *%>@@g;
            s@<%\n*if ( mainClassName.startsWith(.--module .) ) {\n* *%>[^<]*<%\n* *} *%>@@g
            s@<%\n* *if *([^%]*) *{\n* *%>\(\([^<]\|\n\|<<*[^<%]\)*\)<%\n* *}\n* *%>@\1@g
    '
}

case $mode in
    (COMPARE)   generate | diff - "$target" ;;
    (OUTPUT)    generate ;;
    (REPLACE)   generate > "$target" ;;
esac
