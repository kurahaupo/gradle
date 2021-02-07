package Gradle_Promotion.patches.buildTypes

import jetbrains.buildServer.configs.kotlin.v2019_2.*
import jetbrains.buildServer.configs.kotlin.v2019_2.ui.*

/*
This patch script was generated by TeamCity on settings change in UI.
To apply the patch, change the buildType with uuid = '9a55bec1-4e70-449b-8f45-400093505afb' (id = 'Gradle_Promotion_MasterSnapshotFromQuickFeedback')
accordingly, and delete the patch script.
*/
changeBuildType(uuid("9a55bec1-4e70-449b-8f45-400093505afb")) {
    check(paused == false) {
        "Unexpected paused: '$paused'"
    }
    paused = true
}