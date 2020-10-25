FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2019 as build

# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

# Download the Build Tools bootstrapper.
ADD https://aka.ms/vs/16/release/vs_buildtools.exe /vs_buildtools.exe

# Install Build Tools with the Microsoft.VisualStudio.Workload.AzureBuildTools workload, excluding workloads and components with known issues.
RUN vs_buildtools.exe --quiet --wait --norestart --nocache \
    --installPath C:\BuildTools \
    --add Microsoft.Component.MSBuild \
    --add Microsoft.VisualStudio.Component.Windows10SDK.18362 \
    --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64	\
 || IF "%ERRORLEVEL%"=="3010" EXIT 0

# Define the entry point for the docker container.
# This entry point starts the developer command prompt and launches the PowerShell shell.
ENTRYPOINT ["C:\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&", "powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]

RUN curl -fSLo rustup-init.exe https://win.rustup.rs/x86_64
RUN start /w rustup-init.exe -y -v --default-toolchain 1.46.0 && echo "Error level is %ERRORLEVEL%"
RUN del rustup-init.exe

RUN setx /M PATH "C:\Users\ContainerAdministrator\.cargo\bin;%PATH%"
RUN rustup install 1.46.0

COPY Cargo.toml /project/Cargo.toml
COPY Cargo.lock /project/Cargo.lock
COPY src/ /project/src
RUN cargo install --path /project --root /output

#FROM mcr.microsoft.com/windows/nanoserver:1903
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2019

ADD https://download.microsoft.com/download/6/A/A/6AA4EDFF-645B-48C5-81CC-ED5963AEAD48/vc_redist.x64.exe /vc_redist.x64.exe
RUN c:\vc_redist.x64.exe /install /quiet /norestart

COPY --from=build c:/output/bin/windows-docker-web.exe /

CMD ["/windows-docker-web.exe"]
