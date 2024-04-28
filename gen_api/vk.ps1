#
#	Retrieve just the Vulkan XML API Registry:
#
$DestDir = (Get-Location).Path

# Download the vk.xml file
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/KhronosGroup/Vulkan-Docs/main/xml/vk.xml" -OutFile "$DestDir\vk.xml"

# Download the license file
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/KhronosGroup/Vulkan-Docs/main/LICENSE.adoc" -OutFile "$DestDir\LICENSE"
