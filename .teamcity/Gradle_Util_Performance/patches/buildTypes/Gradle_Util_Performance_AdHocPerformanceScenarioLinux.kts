package Gradle_Util_Performance.patches.buildTypes

import jetbrains.buildServer.configs.kotlin.v2019_2.*
import jetbrains.buildServer.configs.kotlin.v2019_2.ui.*

/*
This patch script was generated by TeamCity on settings change in UI.
To apply the patch, change the buildType with uuid = 'Gradle_Util_Performance_AdHocPerformanceScenarioLinux' (id = 'Gradle_Util_Performance_AdHocPerformanceScenarioLinux')
accordingly, and delete the patch script.
*/
changeBuildType(uuid("Gradle_Util_Performance_AdHocPerformanceScenarioLinux")) {
    check(paused == false) {
        "Unexpected paused: '$paused'"
    }
    paused = true
}