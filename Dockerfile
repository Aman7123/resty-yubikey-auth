# Use the openresty:alpine-fat image as the base
FROM openresty/openresty:alpine-fat

# Update the package list
RUN apk update

# Install utils
RUN apk add openssl-dev git

# Install luasec for native HTTPS support
RUN luarocks install luasec

# Install some common Lua libraries
RUN luarocks install luafilesystem
RUN luarocks install luasocket
RUN luarocks install luacheck
RUN luarocks install lua-cjson
RUN luarocks install penlight
RUN luarocks install lua-resty-http
RUN luarocks install lua-resty-string

# Setup container runtime ENV
ENV OPENRESTY_BIN=/usr/local/openresty/bin/openresty

# Copy the docker startup
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD /entrypoint.sh