FROM alpine:latest AS build
RUN apk add --no-cache git build-base cmake perl linux-headers

WORKDIR /src
RUN git clone --recursive https://github.com/luvit/luvi.git

# build luvi
WORKDIR luvi
RUN make regular
RUN make
RUN make test

# build lit
ADD https://lit.luvit.io/packages/luvit/lit/latest.zip lit.zip
RUN echo '#!/usr/local/bin/luvi --' > build/luviprefix 
RUN ln -s /src/luvi/build/luvi /usr/local/bin/luvi
RUN build/luvi lit.zip -- make lit.zip build/lit build/luviprefix

# build luvit
WORKDIR build
RUN ./lit make luvit/luvit luvit luviprefix

# actual base image: just the binaries and their deps
FROM alpine:latest AS luvit
RUN apk add --no-cache libgcc
COPY --from=build /src/luvi/build/luvi /src/luvi/build/lit /src/luvi/build/luvit /usr/local/bin/
