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
# Its use for any other purpose is not supported.
#

app_name=${0##*/}
bin_dir=${0%"$app_name"}
app_dir=${bin_dir%build-logic/jvm/*}
app_dir=${app_dir%.git*}
app_dir_ref=\$APP_HOME/

gradlew_program=    default_gradlew_program=${app_dir}gradlew
gradlew_template=   default_gradlew_template=${app_dir}platforms/jvm/plugins-application/src/main/resources/org/gradle/api/internal/plugins/unixStartScript.txt

################################################################################

# Settings copied from Gradle project configuration

  appHomeRelativePath=
appNameSystemProperty=org.gradle.appname
      applicationName=Gradle
            classpath=${app_dir_ref}gradle/wrapper/gradle-wrapper.jar
       defaultJvmOpts='-Dfile.encoding=UTF-8 "-Xmx64m" "-Xms64m"'
       entryPointArgs=
        mainClassName=org.gradle.wrapper.GradleWrapperMain
           modulePath=
   optsEnvironmentVar=GRADLE_OPTS

# Use -jar instead of -classpath when appropriate
case $classpath in
    *.jar)
       entryPointArgs="-jar \"$classpath\""
            classpath=
        mainClassName=
esac
            classPath=$classpath

################################################################################

# Guestimate

gitRef=$( git log -n1 --format=%H || echo HEAD )

################################################################################

mode=OUTPUT

case $app_name in
    (*check* | *compare*)   mode=COMPARE ;;
    (*gen*)                 mode=REPLACE ;;
    (*)                     mode=OUTPUT ;;
esac

while :; do
    case $1 in
        (-c | --compare)    mode=COMPARE ;;
        (-g | --generate)   mode=REPLACE ;;
        (-G | --git-ref)    gitRef=$2 ; shift ;;
        (-o | --output)     mode=OUTPUT ;;
        (-r | --replace)    mode=REPLACE ;;
        (-s | --source)     gradlew_template=$2 ; shift ;;
             (--source=*)   gradlew_template=${1#*=} ;;
        (-s?*)              gradlew_template=${1#-?} ;;
        (-t | --target)     gradlew_program=$2 ; shift ; applicationName=${gradlew_program##*/} ;;
        (-t?*)              gradlew_program=${1#-?}    ; applicationName=${gradlew_program##*/} ;;
             (--target=*)   gradlew_program=${1#*=}    ; applicationName=${gradlew_program##*/} ;;

        (-h | --help)       cat <<-EndOfHelp ; exit 0 ;;
				$app_name [-c|-g|-o]
				    -c --compare        Compare current version with generated version
                                    -g --generate -r --replace
				                        Overwrite current version with generated version
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

if [ -z "$gradlew_template" ] && [ $# != 0 ]
then
    gradlew_template=$1
    shift
fi
_=${gradlew_template:=$default_gradlew_template}

if [ -z "$gradlew_program" ] && [ $# != 0 ] && [ "$mode" != OUTPUT ]
then
    gradlew_program=$1
    shift
fi
_=${gradlew_program:=$default_gradlew_program}

[ $# = 0 ] || {
    printf >&2 '%s Too many args\n' "$app_name"
    exit 64
}

################################################################################

defaultJvmOpts="'$defaultJvmOpts'"

t=$( sed -e '
            1  h;
            1! H;
            $! d;
            g;
            s/[`]/\\&/g;
            s/\${\([[:alpha:]_][[:alnum:]_]*\) *?: *\([[:alpha:]_][[:alnum:]_]*\)}/${\1:-$\2}/g;
            s@<%\n* */\*\([^*]\|\n\|\*\**[^/*]\)*\*/\n* *%>@@g;
            s@<%\n* *if *( *mainClassName.startsWith(.--module .) *) {\n* *%>[^<]*<%\n* *} *%>@@g;
            s@<%\n* *if *([^%]*) *{\n* *%>\(\([^<]\|\n\|<<*[^<%]\)*\)<%\n* *}\n* *%>@\1@g;
        ' < "$gradlew_template" )

generate() {
    eval 'cat <<EoUSS
'"$t"'
EoUSS'
}

case $mode in
    (COMPARE)   generate | diff - "$gradlew_program" ;;
    (OUTPUT)    generate ;;
    (REPLACE)   generate > "$gradlew_program" ;;
esac
