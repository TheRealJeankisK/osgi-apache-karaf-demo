# Build script for OSGi bundles using the local JDK
# Targets: greeting-service.jar (provider) and greeting-client.jar (consumer)

$ErrorActionPreference = "Stop"

# Setup tools path (using the existing Temurin OpenJDK 21)
$JDKBin = "C:\Users\jeanc\AppData\Local\JDownloader 2\jre\bin"
$javac = Join-Path $JDKBin "javac.exe"
$jar = Join-Path $JDKBin "jar.exe"

# Path to the OSGi core jar from Apache Karaf
$OSGiCoreJar = "tools\apache-karaf-4.4.6\lib\boot\osgi.core-8.0.0.jar"

# Verify tools exist
if (-not (Test-Path $javac)) {
    Write-Error "Java compiler not found at: $javac"
}
if (-not (Test-Path $OSGiCoreJar)) {
    Write-Error "OSGi Core JAR not found at: $OSGiCoreJar"
}

Write-Host "Cleaning up previous build..."
if (Test-Path "out") {
    Remove-Item -Recurse -Force "out"
}
if (Test-Path "greeting-service.jar") {
    Remove-Item -Force "greeting-service.jar"
}
if (Test-Path "greeting-client.jar") {
    Remove-Item -Force "greeting-client.jar"
}

# Create build output folders
New-Item -ItemType Directory -Force -Path "out\provider\classes" | Out-Null
New-Item -ItemType Directory -Force -Path "out\consumer\classes" | Out-Null

Write-Host "Compiling Greeting Service Provider..."
& $javac -d "out\provider\classes" -cp $OSGiCoreJar `
    src\com\example\greeting\GreetingService.java `
    src\com\example\greeting\impl\GreetingServiceImpl.java `
    src\com\example\greeting\impl\Activator.java

Write-Host "Packaging Greeting Service Provider (greeting-service.jar)..."
& $jar cfm greeting-service.jar manifests\provider.mf -C out\provider\classes .

Write-Host "Compiling Greeting Client Consumer..."
# The client needs both OSGi framework and the GreetingService interface (contained in the provider output classes)
$ClientCP = "$OSGiCoreJar;out\provider\classes"
& $javac -d "out\consumer\classes" -cp $ClientCP `
    src\com\example\client\Activator.java

Write-Host "Packaging Greeting Client (greeting-client.jar)..."
& $jar cfm greeting-client.jar manifests\consumer.mf -C out\consumer\classes .

Write-Host "Build complete! Generated:"
Write-Host "  - greeting-service.jar"
Write-Host "  - greeting-client.jar"
