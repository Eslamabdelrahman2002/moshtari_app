// build.gradle.kts

buildscript {
    // ❌ تم حذف val kotlinVersion by extra("1.7.10") لمنع تضارب إصدارات Kotlin

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // تم تحديث إصدار Gradle ليناسب 8.7.3 من settings.gradle.kts
        classpath("com.android.tools.build:gradle:8.7.3")
        // ❌ تم حذف classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
        // أصبح يتم تحميل Kotlin من خلال plugins block في settings.gradle.kts
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: File = rootProject.layout.buildDirectory.dir("../../build").get().asFile
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir: File = newBuildDir.resolve(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}