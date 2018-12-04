package Gradle_R4.patches.buildTypes

import jetbrains.buildServer.configs.kotlin.v2018_1.*
import jetbrains.buildServer.configs.kotlin.v2018_1.triggers.VcsTrigger
import jetbrains.buildServer.configs.kotlin.v2018_1.triggers.vcs
import jetbrains.buildServer.configs.kotlin.v2018_1.ui.*

/*
This patch script was generated by TeamCity on settings change in UI.
To apply the patch, change the buildType with uuid = 'Gradle_R4_Stage_MasterAccept_Trigger' (id = 'Gradle_R4_Stage_ReadyforNightly_Trigger')
accordingly, and delete the patch script.
*/
changeBuildType(uuid("Gradle_R4_Stage_MasterAccept_Trigger")) {
    triggers {
        val trigger1 = find<VcsTrigger> {
            vcs {
                quietPeriodMode = VcsTrigger.QuietPeriodMode.USE_CUSTOM
                quietPeriod = 90
                triggerRules = """
                    -:design-docs
                    -:subprojects/docs/src/docs/release
                """.trimIndent()
                branchFilter = """
                    +:master
                    +:release
                """.trimIndent()
            }
        }
        trigger1.apply {
            branchFilter = "+:release-4.10"
        }
    }
}
