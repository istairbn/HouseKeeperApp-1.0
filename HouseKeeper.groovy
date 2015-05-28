/*
HouseKeeper.groovy
 */
import groovy.json.*

def props = args.length > 0 ? ".\\lib\\" + args[0] : "\\lib\\config.properties"

Properties properties
properties = new Properties()
File propertiesFile
propertiesFile = new File(props)

if (propertiesFile.exists()){
    propertiesFile.withInputStream{
        properties.load(it)
    }
}
else{
    println "No config.properties File Present in lib folder"
    println System.getProperty("user.dir")
    return //1
}

def now = new Date().format("yyyy/MM/dd HH:mm:ss:SSS ZZZ")

def jsonSlurper1 = new JsonSlurper()
def jsonSlurper2 = new JsonSlurper()
def jsonSlurper3 = new JsonSlurper()
def jsonSlurper4 = new JsonSlurper()

def source = properties.targets
def exts = properties.extensions
def limits = properties.timelimit
def recursion = properties.recursion

def targets = jsonSlurper1.parseText(source)
def extensions = jsonSlurper2.parseText(exts)
def times = jsonSlurper3.parseText(limits)
def recursive = jsonSlurper4.parseText(recursion)

assert targets instanceof Map
assert extensions instanceof Map
assert times instanceof Map
assert recursive instanceof Map

targets.each { folder ->
    File file = new File(folder.value)

    def targetExtension = "."
    extensions.each { ext ->
        if (folder.key == ext.key) {
            targetExtension = ext.value
        }
    }

    def targetTime = 1440
    times.each { t ->
        if (folder.key == t.key) {
            targetTime = t.value
        }
    }

    def recurse = false
    recursive.each { r ->
        if (folder.key == r.key) {
            recurse = r.value
        }
    }

    if (file.exists()) {
        if (recurse == "true") {
            file.eachFileRecurse { it ->
                def modified = new Date(it.lastModified())
                def modTime = new Date(it.lastModified()).format("yyyy/MM/dd HH:mm:ss:SSS ZZZ")
                def size = it.length()
                def age = new Double((new Date().time - modified.time) / 1000 / 60).round(2)
                def deadline = targetTime.toInteger()
                def difference = age - deadline

                    if (it.name.contains(targetExtension)) {

                        if (difference > 0) {
                            println "$now,INFO Name:$folder.key File:$it.absolutePath Filename:$it.name ModifiedDate:$modTime Bytes:$size Age:$age MaxAge:$deadline Action:DELETE"
                            it.delete()
                        } else {
                            println "$now,INFO, Name:$folder.key File:$it.absolutePath Filename:$it.name ModifiedDate:$modTime Bytes:$size Age:$age MaxAge:$deadline Action:NONE"
                        }
                    }
                }
            }
         else {
            file.eachFile { it ->
                def modified = new Date(it.lastModified())
                def modTime = new Date(it.lastModified()).format("yyyy/MM/dd HH:mm:ss:SSS ZZZ")
                def size = it.length()
                def age = new Double((new Date().time - modified.time) / 1000 / 60).round(2)
                def deadline = targetTime.toInteger()
                def difference = age - deadline

                if (it.name.contains(targetExtension)) {

                    if (difference > 0) {
                        println "$now,INFO, Name:$folder.key File:$it.absolutePath Filename:$it.name ModifiedDate:$modTime Bytes:$size Age:$age MaxAge:$deadline Action:DELETE"
                        it.delete()
                    } else {
                        println "$now,INFO, Name:$folder.key File:$it.absolutePath Filename:$it.name ModifiedDate:$modTime Bytes:$size Age:$age MaxAge:$deadline Action:NONE "
                    }
                }
            }
            }
        }
        else {
        println "$now,WARN, Name:$folder.key File:$folder.value fileNotFoundException:Missing File"
        }
    }
