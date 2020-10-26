FROM mcr.microsoft.com/windows/nanoserver:1809 as build

# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

RUN curl -fSLo rustup-init.exe https://win.rustup.rs/x86_64
RUN start /w rustup-init.exe -y -v && echo "Error level is %ERRORLEVEL%"
RUN del rustup-init.exe

USER ContainerAdministrator
RUN setx /M PATH "C:\Users\ContainerUser\.cargo\bin;%PATH%"
USER ContainerUser

COPY Cargo.toml /project/Cargo.toml
COPY Cargo.lock /project/Cargo.lock
COPY rust-toolchain /project/rust-toolchain
COPY src/ /project/src
RUN rustup set default-host x86_64-pc-windows-gnu
RUN cd /project && cargo install --path . --root /output

FROM mcr.microsoft.com/windows/nanoserver:1809

COPY --from=build c:/output/bin/windows-docker-web.exe /

CMD ["/windows-docker-web.exe"]
