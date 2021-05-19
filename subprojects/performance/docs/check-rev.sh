#!/bin/sh
# script to be used for Gradle performance test bisecting
# example usage:
# git bisect start HEAD REL_2.14 --  # HEAD=bad REL_2.14=good
# git bisect run check_rev.sh JavaConfigurationPerformanceTest lotDependencies

TESTNAME=${1:-IdeIntegrationPerformanceTest}
TESTPROJECT=${2:-multi}

gbo="$HOME"/.gradle-bisect-override
gbs="$HOME"/.gradle-bisect-override-script
gbr="$HOME"/.gradle-bisect-results

./gradlew clean

[ -d "$gbo" ] && cp -Rdvp "$gbo"/* .
[ -x "$gbs" ] && "$gbs" "$TESTNAME" "$TESTPROJECT"
./gradlew -S -PtimestampedVersion \
          -x :performance:prepareSamples \
             :performance:"$TESTPROJECT" \
             :performance:cleanPerformanceTest \
             :performance:performanceTest \
           -D:performance:performanceTest.single="$TESTNAME"
result=$?
datets=$( date +%F-%T )

hash=$( git rev-parse --short HEAD )

mkdir -p "$gbr"
cp "subprojects/performance/build/test-results/performanceTest/TEST-org.gradle.performance.$TESTNAME.xml" \
   "$gbr/result_${result}_${hash}_${datets}.xml"

git reset --hard
exit $result
